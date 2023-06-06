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

#include "RebroadcastDecider.h"
#include "../CarJammingAnnouncement_m.h"
#include "../BaseApplicationLayer.h"

using namespace drones_veins_project;

Define_Module(drones_veins_project::RebroadcastDecider);

RebroadcastDecider::RebroadcastDecider()
{

}

RebroadcastDecider::~RebroadcastDecider()
{
	// TODO Auto-generated destructor stub
}

veins::Coord RebroadcastDecider::getCurrentPosition() const
{
	BaseApplicationLayer *parent = dynamic_cast<BaseApplicationLayer*>(getParentModule());
	ASSERT(parent);
	veins::Coord receiverPos = parent->getCurrentPosition();
	return receiverPos;
}

double RebroadcastDecider::getDistance(cMessage *msg)
{
	CarJammingAnnouncement *jamMsg = dynamic_cast<CarJammingAnnouncement*>(msg);
	ASSERT(jamMsg);
	veins::Coord senderPos = jamMsg->getLastRebroadcasterPosition();

	veins::Coord receiverPos = getCurrentPosition();

	double distance = senderPos.distance(receiverPos);
	return distance;
}

void RebroadcastDecider::initialize(int stage)
{
	cSimpleModule::initialize(stage);

	parentInGate = findGate("parentInGate");

	if (hasPar("rebroadcastProbability"))
	{
		probability = par("rebroadcastProbability").doubleValue();
	}
	else
	{
		probability = 0;
	}
}

int RebroadcastDecider::getParentInGate()
{
	return parentInGate;
}

void RebroadcastDecider::registerMessage(cMessage *msg)
{
	if (CarJammingAnnouncement *jamMsg = dynamic_cast<CarJammingAnnouncement*>(msg))
	{
		veins::LAddress::L2Type senderAddress = jamMsg->getSenderAddress();
		if (senderAddress <= 0)
		{
			return;
		}

		receivedMessagesTable[senderAddress] = jamMsg->getSerial();
	}
}

void RebroadcastDecider::handleMessage(omnetpp::cMessage *msg)
{
	if (shouldRebroadcast(msg))
	{
		rebroadcast(msg);
	}
}

bool RebroadcastDecider::isUnique(cMessage *msg)
{
	if (CarJammingAnnouncement *jamMsg = dynamic_cast<CarJammingAnnouncement*>(msg))
	{
		veins::LAddress::L2Type senderAddress = jamMsg->getSenderAddress();
		long serial = jamMsg->getSerial();
		return receivedMessagesTable.count(senderAddress) == 0 || receivedMessagesTable[senderAddress] < serial;
	}
	return false;
}

bool RebroadcastDecider::shouldRebroadcast(cMessage *msg)
{
	if (CarJammingAnnouncement *jamMsg = dynamic_cast<CarJammingAnnouncement*>(msg))
	{

		if (!isUnique(jamMsg))
		{
			// This is a duplicated or an outdated message
			return false;
		}

		registerMessage(jamMsg);

		double rnd = uniform(0.0, 1.0, 0);

		return probability > rnd;
	}
	return false;
}

void RebroadcastDecider::rebroadcast(cMessage *msg)
{
	BaseApplicationLayer *bLayer = dynamic_cast<BaseApplicationLayer*>(getParentModule());
	ASSERT(bLayer);
	int gate = bLayer->findGate("rebroadcastDeciderInGate");
	ASSERT(gate != -1);

	if (CarJammingAnnouncement *jamMsg = dynamic_cast<CarJammingAnnouncement*>(msg))
	{
		jamMsg->setLastRebroadcasterPosition(getCurrentPosition());
		jamMsg->setHop(jamMsg->getHop() + 1);
	}

	sendDirect(msg, bLayer, gate);
}
