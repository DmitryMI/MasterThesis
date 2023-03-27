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

#include "BaseApplicationLayer.h"
#include "veins/base/utils/FindModule.h"
#include "PeriodicSafetyMessage_m.h"
#include <cassert>

using namespace drones_veins_project;

veins::LAddress::L2Type BaseApplicationLayer::addressCounter = 1;

veins::LAddress::L2Type BaseApplicationLayer::getAddress()
{
	return address;
}

BaseApplicationLayer::BaseApplicationLayer()
{
	// TODO Auto-generated constructor stub

}

BaseApplicationLayer::~BaseApplicationLayer()
{
	// TODO Auto-generated destructor stub
}

void BaseApplicationLayer::handleMessage(cMessage *msg)
{
	//DemoBaseApplLayer::handleMessage(msg);

	if (msg->arrivedOn("rebroadcastDeciderInGate"))
	{
		sendDown(msg);
	}
	else
	{
		DemoBaseApplLayer::handleMessage(msg);
	}

}

void BaseApplicationLayer::initialize(int stage)
{
	DemoBaseApplLayer::initialize(stage);

	if (stage == 0)
	{
		address = addressCounter;
		addressCounter++;

		rebroadcastDeciderInGate = findGate("rebroadcastDeciderInGate");

		WATCH(address);
	}
}

void BaseApplicationLayer::onWSM(veins::BaseFrame1609_4 *wsm)
{
	DemoBaseApplLayer::onWSM(wsm);

	if (CarJammingAnnouncement *jamAnnouncement = dynamic_cast<CarJammingAnnouncement*>(wsm))
	{
		// handleCarJammingAnnouncement is responsible for forwarding the message to RD
		handleCarJammingAnnouncement(jamAnnouncement);
	}

	RebroadcastDecider *rd = getRebroadcastDecider();
	if (rd)
	{
		sendDirect(wsm->dup(), rd, rd->getParentInGate());
	}

}

void BaseApplicationLayer::onBSM(veins::DemoSafetyMessage *bsm)
{
	DemoBaseApplLayer::onBSM(bsm);
	RebroadcastDecider *rd = getRebroadcastDecider();
	if (rd)
	{
		sendDirect(bsm->dup(), rd, rd->getParentInGate());
	}
}

void BaseApplicationLayer::handleSelfMsg(cMessage *msg)
{
	if (CarJammingAnnouncement *jamAnnouncement = dynamic_cast<CarJammingAnnouncement*>(msg))
	{
		sendDown(jamAnnouncement);
	}
	else if (msg->getKind() == SEND_BEACON_EVT)
	{
		// Overriding beaconing
		PeriodicSafetyMessage *bsm = new PeriodicSafetyMessage();
		populateWSM(bsm);
		// TODO Set heading
		sendDown(bsm);
		scheduleAt(simTime() + beaconInterval, sendBeaconEvt);
	}
	else
	{
		DemoBaseApplLayer::handleSelfMsg(msg);
	}
}

void BaseApplicationLayer::handleCarJammingAnnouncement(CarJammingAnnouncement *msg)
{
	RebroadcastDecider *rebroadcastDecider = getRebroadcastDecider();

	if (rebroadcastDecider->shouldRebroadcast(msg))
	{
		scheduleAt(simTime() + 2 + uniform(0.01, 0.2), msg->dup());
	}
	else
	{
		// Do not delete the WSM message! DemoBaseApplLayer does it automatically.
		// delete msg;
	}

	setIconColor("green");
}

void BaseApplicationLayer::setIconColor(std::string color)
{
	cModule *hostModule = findHost();
	assert(hostModule);
	hostModule->getDisplayString().setTagArg("i", 1, color.c_str());
}

std::string BaseApplicationLayer::getIconColor()
{
	cModule *hostModule = findHost();
	assert(hostModule);
	const char *tagArg = hostModule->getDisplayString().getTagArg("i", 1);
	return tagArg;
}

RebroadcastDecider* BaseApplicationLayer::getRebroadcastDecider()
{
	return veins::FindModule<RebroadcastDecider*>::findSubModule(this);;
}

int BaseApplicationLayer::getRebroadcastDeciderInGate()
{
	return rebroadcastDeciderInGate;
}

