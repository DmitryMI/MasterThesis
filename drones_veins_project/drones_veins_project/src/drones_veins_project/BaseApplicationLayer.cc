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
#include <iomanip>

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

veins::Coord BaseApplicationLayer::getCurrentPosition() const
{
	return curPosition;
}

omnetpp::cFigure::Color BaseApplicationLayer::calculateNodeColor() const
{
	int nodeIndex = this->getParentModule()->getIndex();

	uint64_t a = 1103515245;
	uint64_t c = 12345;
	uint64_t m = 2UL << 31;
	uint64_t seed = 12345 + nodeIndex;
	std::array<int, 3> values;

	seed = (a * seed + c) % m;
	for (uint64_t i = 0; i < values.size(); i++)
	{
		values[i] = (uint8_t) (seed >> i);
	}

	omnetpp::cFigure::Color color = omnetpp::cFigure::Color(values[0], values[1], values[2]);
	return color;
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

void BaseApplicationLayer::finish()
{
	veins::DemoBaseApplLayer::finish();

	if (latencies.size() > 0)
	{
		double latency_sum = 0;
		for (double latency : latencies)
		{
			latency_sum += latency;
		}

		double latency_avg = latency_sum / latencies.size();

		recordScalar("latencyAverage", latency_avg);
	}

	if (hops.size() > 0)
	{
		double hops_sum = 0;
		for (long hop : hops)
		{
			hops_sum += hop;
		}

		double hops_avg = hops_sum / hops.size();
		recordScalar("hopsAverage", latency_avg);
	}
}

void BaseApplicationLayer::onWSM(veins::BaseFrame1609_4 *wsm)
{
	DemoBaseApplLayer::onWSM(wsm);

	if (CarJammingAnnouncement *jamAnnouncement = dynamic_cast<CarJammingAnnouncement*>(wsm))
	{
		// handleCarJammingAnnouncement is responsible for forwarding the message to RD
		handleCarJammingAnnouncement(jamAnnouncement);

		RebroadcastDecider *rd = getRebroadcastDecider();
		if (rd)
		{
			sendDirect(wsm->dup(), rd, rd->getParentInGate());
		}

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
	if (simTime() >= getSimulation()->getWarmupPeriod())
	{
		double time = simTime().dbl();
		double latency = time - msg->getSenderTimestamp().dbl();
		int hop = time - msg->getHop();
		ASSERT(latency > 0);
		latencies.push_back(latency);
		hops.push_back(hop);
	}

	setIconColor("green");
}

void BaseApplicationLayer::setIconColorStr(std::string color)
{
	cModule *hostModule = findHost();
	assert(hostModule);
	hostModule->getDisplayString().setTagArg("i", 1, color.c_str());
}

void BaseApplicationLayer::setIconColor(omnetpp::cFigure::Color color)
{
	std::stringstream stream;
	stream << "#" << std::setfill('0') << std::setw(2) << std::hex << (int) color.red << std::setw(2) << std::hex
			<< (int) color.green << std::setw(2) << std::hex << (int) color.blue;
	std::string colorStr = stream.str();
	setIconColorStr(colorStr);
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
	return veins::FindModule<RebroadcastDecider*>::findSubModule(this);
}

int BaseApplicationLayer::getRebroadcastDeciderInGate()
{
	return rebroadcastDeciderInGate;
}

