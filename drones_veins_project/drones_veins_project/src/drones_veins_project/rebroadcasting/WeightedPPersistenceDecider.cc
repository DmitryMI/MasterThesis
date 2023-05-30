//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

#include "WeightedPPersistenceDecider.h"
#include "veins/base/utils/SimpleAddress.h"
#include "../drones_veins_project.h"
#include "../CarJammingAnnouncement_m.h"
#include "../BaseApplicationLayer.h"

using namespace drones_veins_project;

Define_Module(drones_veins_project::WeightedPPersistenceDecider);

WeightedPPersistenceDecider::WeightedPPersistenceDecider()
{
	// TODO Auto-generated constructor stub

}

WeightedPPersistenceDecider::~WeightedPPersistenceDecider()
{
	for (auto &pair : rebroadcastingQueue)
	{
		cMessage *wsm = pair.first;
		cancelAndDelete(wsm);
	}

	for (auto &pair : dieOutBuffer)
	{
		cMessage *wsm = pair.first;
		cMessage *dieOutWaitMessage = pair.second;
		cancelAndDelete(dieOutWaitMessage);
		cancelAndDelete(wsm);
	}
}

void WeightedPPersistenceDecider::initialize(int stage)
{
	waitTime = par("waitTime").doubleValue();
	waitTimeDeviation = par("waitTimeDeviation").doubleValue();
	deltaTime = par("deltaTime").doubleValue();
	averageTransmissionRange = par("averageTransmissionRange").doubleValue();
	showBubbles = par("showBubbles").boolValue();
}

void WeightedPPersistenceDecider::handleSelfMessage(omnetpp::cMessage *selfMsg)
{
	std::string msgName = selfMsg->getName();
	if (msgName == "rebroadcastWait")
	{
		cMsgPar &messagePar = selfMsg->par("message");
		cMessage *queuedMessage = dynamic_cast<cMessage*>(messagePar.getObjectValue());
		ASSERT(queuedMessage);

		cancelAndDelete(selfMsg);
		selfMsg = nullptr;

		double probability = rebroadcastingQueue.at(queuedMessage);
		rebroadcastingQueue.erase(queuedMessage);

		double rnd = uniform(0.0, 1.0, 0);

		bool willRebroadcast = probability > rnd;
		if (willRebroadcast)
		{
			rebroadcast(queuedMessage->dup());
			cancelAndDelete(queuedMessage);

			char text[64];
			sprintf(text, "Rebroacasting!");
			showBubble(text);

		}
		else
		{
			cMessage *dieOutWaitMessage = new cMessage("dieOutWait");
			cMsgPar &messagePar = dieOutWaitMessage->addPar("message");
			messagePar.setTakeOwnership(false);
			messagePar.setObjectValue(queuedMessage);

			dieOutBuffer.emplace(queuedMessage, dieOutWaitMessage);
			scheduleAt(simTime() + waitTime + deltaTime, dieOutWaitMessage);

			char text[64];
			sprintf(text, "Added to DieOut!");
			showBubble(text);

		}
	}
	else if (msgName == "dieOutWait")
	{
		cMsgPar &messagePar = selfMsg->par("message");
		// cMessage *queuedMessage = (cMessage*)(messagePar.pointerValue());
		cMessage *queuedMessage = dynamic_cast<cMessage*>(messagePar.getObjectValue());
		ASSERT(queuedMessage);

		cancelAndDelete(selfMsg);
		selfMsg = nullptr;

		if (dieOutBuffer.count(queuedMessage) != 0)
		{
			// Nobody rebroadcasted! We must do it with 100% probability!
			rebroadcast(queuedMessage->dup());
			dieOutBuffer.erase(queuedMessage);
			cancelAndDelete(queuedMessage);

			char text[64];
			sprintf(text, "DieOut prevented!");
			showBubble(text);

		}
	}

}

void WeightedPPersistenceDecider::showBubble(const char *text)
{
	if (hasGUI() && showBubbles)
	{
		cModule *node = getParentModule()->getParentModule();
		ASSERT(node);
		node->bubble(text);
	}
}

void WeightedPPersistenceDecider::handleMessage(omnetpp::cMessage *msg)
{
	if (msg->isSelfMessage())
	{
		handleSelfMessage(msg);
		return;
	}

	CarJammingAnnouncement *jamMsg = dynamic_cast<CarJammingAnnouncement*>(msg);
	if (!jamMsg)
	{
		return;
	}

	if (CarJammingAnnouncement *dieOutBuffered = getEqualMessageMap<CarJammingAnnouncement,
			std::map<cMessage*, cMessage*>>(jamMsg, dieOutBuffer))
	{

		showBubble("DieOut Received!");

		// Message was retransmitted by somebody else
		cMessage *dieOutWaitMessage = dieOutBuffer.at(dieOutBuffered);
		cancelAndDelete(dieOutWaitMessage);
		dieOutBuffer.erase(dieOutBuffered);
		cancelAndDelete(dieOutBuffered);
		cancelAndDelete(jamMsg);
		return;
	}

	double distance = getDistance(jamMsg);
	double probability = distance / averageTransmissionRange;
	if (probability > 1.0)
	{
		probability = 1.0;
	}

	if (CarJammingAnnouncement *rebroadcastQueued = getEqualMessageMap<CarJammingAnnouncement,
			std::map<cMessage*, double>>(jamMsg, rebroadcastingQueue))
	{
		// Message was received earlier but not retransmitted yet, update retransmission probability
		double probabilityInQueue = rebroadcastingQueue[rebroadcastQueued];
		if (probability < probabilityInQueue)
		{
			char text[64];
			sprintf(text, "Queued message received. p=%.2f -> %.2f", probabilityInQueue, probability);
			showBubble(text);

			rebroadcastingQueue[rebroadcastQueued] = probability;
		}
		else
		{
			char text[64];
			sprintf(text, "Queued message received. p=%.2f", probabilityInQueue);
			showBubble(text);
		}

		cancelAndDelete(jamMsg);
		return;
	}

	if (!isUnique(jamMsg))
	{
		// This message was received earlier, discard
		showBubble("Duplicate!");
		cancelAndDelete(jamMsg);
		return;
	}

	// This is a new message
	registerMessage(jamMsg);

	// Add message to waiting queue
	rebroadcastingQueue.emplace(jamMsg, probability);

	// Schedule retransmission
	cMessage *rebroadcastWaitMessage = new cMessage("rebroadcastWait");
	cMsgPar &messagePar = rebroadcastWaitMessage->addPar("message");
	messagePar.setTakeOwnership(false);
	messagePar.setObjectValue(jamMsg);
	double waitTimeRandom = waitTime + uniform(-waitTimeDeviation, waitTimeDeviation);
	scheduleAt(simTime() + waitTimeRandom, rebroadcastWaitMessage);

	char text[64];
	sprintf(text, "Waiting for %.2f s, p=%.2f", waitTimeRandom, probability);
	showBubble(text);

}

