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

#include "CarApplicationLayer.h"
#include "../VehicleCounter.h"

Define_Module(drones_veins_project::CarApplicationLayer);

using namespace drones_veins_project;

CarApplicationLayer::CarApplicationLayer()
{
	auto jammingDetectedCallback = [this](bool jammed) -> void
	{	onCarJammingStateChanged(jammed);};
	jammingDetector.setCallback(jammingDetectedCallback);
}

CarApplicationLayer::~CarApplicationLayer()
{

}

void CarApplicationLayer::initialize(int stage)
{
	// Required for proper initialization
	BaseApplicationLayer::initialize(stage);

	WATCH(totalTimeInJam);

	if (stage == 0)
	{
	    VehicleCounter* counter = VehicleCounter::getInstance();
	    ASSERT(counter);
	    counter->incrementVehiclesSpawned();
	}
}

void CarApplicationLayer::finish()
{
	BaseApplicationLayer::finish();

	VehicleCounter* counter = VehicleCounter::getInstance();
	ASSERT(counter);
	counter->incrementVehiclesDestroyed();

	if(jammingDetector.isJammedNow())
	{
		totalTimeInJam += (simTime() - jammingDetector.getJamStartTimestamp()).dbl();
	}

	recordScalar("totalTimeInJam", totalTimeInJam);
	recordScalar("receivedJammingAnnouncementsNum", receivedJammingAnnouncements.size());
}

std::string CarApplicationLayer::getCarDescriptor()
{
	cModule *module = getParentModule();
	ASSERT(module);
	std::string carName(module->getName());
	std::stringstream ss;
	ss << carName << "(roadId: " << mobility->getRoadId() << ", position: " << curPosition << ")";

	std::string text = ss.str();
	return text;
}

void CarApplicationLayer::onCarJammingStateChanged(bool jammed)
{
	if (jammed)
	{
		EV << "Car " << getCarDescriptor() << " jammed!";
		setIconColor("red");

		if(par("jammingAnnouncementEnabled").boolValue())
		{
			CarJammingAnnouncement *msg = new CarJammingAnnouncement();
			populateWSM(msg);

			msg->setCarPosition(curPosition);
			msg->setCarRoadId(mobility->getRoadId().c_str());
			msg->setSenderAddress(getAddress());
			msg->setSerial(messageSerialCounter);
			msg->setTimestamp();
			msg->setSenderTimestamp(simTime());
			messageSerialCounter++;
			sendDown(msg);
		}
	}
	else
	{
		totalTimeInJam += (simTime() - jammingDetector.getJamStartTimestamp()).dbl();

		setIconColor("white");
		EV << "Car " << getCarDescriptor() << " is no longer jammed!";
	}
}

void CarApplicationLayer::updateJammingDetector()
{
	jammingDetector.updateJammingDetector(mobility->getSpeed());
}

void CarApplicationLayer::onWSM(veins::BaseFrame1609_4 *wsm)
{
	BaseApplicationLayer::onWSM(wsm);
}

void CarApplicationLayer::onWSA(veins::DemoServiceAdvertisment *wsa)
{
	// Never used
}

void CarApplicationLayer::handleCarJammingAnnouncement(CarJammingAnnouncement *msg)
{
	BaseApplicationLayer::handleCarJammingAnnouncement(msg);

	veins::LAddress::L2Type sender = msg->getSenderAddress();
	if(sender == getAddress())
	{
		// Ignore own messages
		return;
	}

	if (mobility->getRoadId()[0] != ':')
	{
		std::string roadId = msg->getCarRoadId();
		traciVehicle->changeRoute(roadId, 9999);
	}

	if (simTime() >= getSimulation()->getWarmupPeriod())
	{
        if (receivedJammingAnnouncements.count(sender) == 0)
        {
            receivedJammingAnnouncements.insert(sender);
        }
	}

}

void CarApplicationLayer::handleSelfMsg(cMessage *msg)
{
	BaseApplicationLayer::handleSelfMsg(msg);
}

void CarApplicationLayer::handlePositionUpdate(cObject *obj)
{
	setIconColor("white");

	DemoBaseApplLayer::handlePositionUpdate(obj);

	updateJammingDetector();
}

