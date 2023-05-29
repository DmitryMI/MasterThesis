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
#include "../pathfinding/Pathfinder.h"
#include "veins/base/utils/FindModule.h"

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
	// clearCanvasRouteFigures();
}

void CarApplicationLayer::initialize(int stage)
{
	// Required for proper initialization
	BaseApplicationLayer::initialize(stage);

	WATCH(totalTimeInJam);
	WATCH(currentRouteId);

	if (stage == 0)
	{
		VehicleCounter *counter = VehicleCounter::getInstance();
		ASSERT(counter);
		counter->incrementVehiclesSpawned();
	}
}

void CarApplicationLayer::finish()
{
	BaseApplicationLayer::finish();

	this->clearCanvasRouteFigures();

	VehicleCounter *counter = VehicleCounter::getInstance();
	ASSERT(counter);
	counter->incrementVehiclesDestroyed();

	if (jammingDetector.isJammedNow())
	{
		totalTimeInJam += (simTime() - jammingDetector.getJamStartTimestamp()).dbl();
	}

	recordScalar("totalTimeInJam", totalTimeInJam);
	recordScalar("receivedJammingAnnouncementsNum", receivedJammingAnnouncements.size());
	// recordScalar("actualRoute", actualRoute.str());
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
		setIconColorStr("red");

		if (par("jammingAnnouncementEnabled").boolValue())
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

		setIconColor(calculateNodeColor());
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
	if (sender == getAddress())
	{
		// Ignore own messages
		return;
	}

	std::string jammedRoadId = msg->getCarRoadId();
	if (disallowedEdges.count(jammedRoadId) == 0)
	{
		disallowedEdges.insert(jammedRoadId);

		auto currentRouteEdges = traciVehicle->getPlannedRoadIds();
		bool plannedDisallowedEdge = false;
		for (auto edge : currentRouteEdges)
		{
			if (edge == jammedRoadId)
			{
				plannedDisallowedEdge = true;
				break;
			}
		}

		if (plannedDisallowedEdge)
		{
			changeRoute();
		}
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
	std::string msgName = msg->getName();
	if (msgName == "changeRoute")
	{
		changeRoute(msg);
	}
	else
	{
		BaseApplicationLayer::handleSelfMsg(msg);
	}
}

void CarApplicationLayer::handlePositionUpdate(cObject *obj)
{
	// setIconColorStr("white");
	setIconColor(calculateNodeColor());

	DemoBaseApplLayer::handlePositionUpdate(obj);

	updateJammingDetector();

	if (par("drawVehicleRoute").boolValue())
	{
		std::string routeId = traciVehicle->getRouteId();
		currentRouteId = routeId;
	}
}

void CarApplicationLayer::changeRoute(cMessage *changeRouteMessage)
{
	int index = getParentModule()->getIndex();
	EV << "Vehicle [" << index << "] changes route!\n";

	Pathfinder *pathfinder = veins::FindModule<Pathfinder*>::findGlobalModule();
	ASSERT(pathfinder);

	double minRouteDistance = par("minRouteDistance").doubleValue();

	bool routeChanged = false;
	try
	{
		if (traciVehicle->getRoadId().find(':') != std::string::npos)
		{
			EV << "Vehicle [" << index << "] must leave the junction before changing route!\n";
		}
		else
		{
			std::string startEdge = traciVehicle->getRoadId();
			std::list<std::string> route;
			bool routeGenerated = pathfinder->generateRandomRouteStr(startEdge, route, disallowedEdges,
					minRouteDistance);
			if(routeGenerated)
			{
				routeChanged = traciVehicle->changeVehicleRoute(route);
			}
		}

	}
	catch (const cRuntimeError &ex)
	{
		routeChanged = false;
		// EV << ex.getMessage() << "\n";
	}

	double delay;
	if (!routeChanged)
	{

		if (changeRouteMessage == nullptr)
		{
			changeRouteMessage = new cMessage("changeRoute");
			cMsgPar &delayPar = changeRouteMessage->addPar("delay");
			delayPar.setDoubleValue(2);
			delay = 2;
		}
		else
		{
			cMsgPar delayPar = changeRouteMessage->par("delay");
			delayPar.setDoubleValue(delayPar.doubleValue() * 2);
			delay = delayPar.doubleValue();
		}
		ASSERT(delay > 0);
		EV << "Vehicle [" << index << "] failed to change route! Retrying in " << delay << "seconds";
		scheduleAt(simTime() + delay, changeRouteMessage);
	}
	else
	{
		lastShownRouteId = "";
		if (changeRouteMessage)
		{
			delete changeRouteMessage;
		}
	}
}

void CarApplicationLayer::clearCanvasRouteFigures() const
{
	cCanvas *canvas = getSimulation()->getSystemModule()->getCanvas();
	std::string groupName = "Vehicle " + std::to_string(this->getParentModule()->getIndex()) + " route";
	int groupFigureIndex = canvas->findFigure(groupName.c_str());
	if (groupFigureIndex != -1)
	{
		cFigure *group = canvas->getFigure(groupFigureIndex);
		canvas->removeFigure(groupFigureIndex);
		delete group;
	}
}

void CarApplicationLayer::refreshDisplay() const
{
	BaseApplicationLayer::refreshDisplay();

	if (hasGUI())
	{
		if (par("drawVehicleRoute").boolValue())
		{
			drawVehicleRoute();
		}
		else
		{
			clearCanvasRouteFigures();
		}
	}
}

void CarApplicationLayer::drawVehicleRoute() const
{
	if (currentRouteId == lastShownRouteId)
	{
		return;
	}

	lastShownRouteId = currentRouteId;

	if (currentRouteId.empty())
	{
		clearCanvasRouteFigures();
		lastShownRouteId = currentRouteId;
		return;
	}

	std::string groupName = "Vehicle " + std::to_string(this->getParentModule()->getIndex()) + " route";
	cGroupFigure *group = nullptr;
	cCanvas *canvas = getSimulation()->getSystemModule()->getCanvas();
	int groupFigureIndex = canvas->findFigure(groupName.c_str());
	if (groupFigureIndex == -1)
	{
		group = new cGroupFigure(groupName.c_str());
		group->setZIndex(par("routeZIndex").doubleValue() + getIndex());
		canvas->addFigure(group);
	}
	else
	{
		group = dynamic_cast<cGroupFigure*>(canvas->getRootFigure()->getFigure(groupFigureIndex));
	}

	ASSERT(traciVehicle);
	// veins::TraCICommandInterface::Route route = veins::TraCICommandInterface::Route(traci, currentRouteId);
	// std::list<std::string> routeEdges = route.getRoadIds();
	std::list<std::string> routeEdges = traciVehicle->getPlannedRoadIds();
	int figureCounter = 0;
	for (std::string edgeId : routeEdges)
	{
		veins::TraCICommandInterface::Road edge = veins::TraCICommandInterface::Road(traci, edgeId);
		auto laneIds = edge.getRoadLaneIds();
		for (auto laneId : laneIds)
		{
			veins::TraCICommandInterface::Lane lane(traci, laneId);
			auto coords = lane.getShape();
			cPolylineFigure *edgeFigure = nullptr;
			if (group->getNumFigures() >= figureCounter)
			{
				edgeFigure = new cPolylineFigure(std::to_string(figureCounter).c_str());
				group->addFigure(edgeFigure);
				omnetpp::cFigure::Color lineColor = calculateNodeColor();
				edgeFigure->setLineColor(lineColor);
				edgeFigure->setLineWidth(3);
			}
			else
			{
				edgeFigure = dynamic_cast<cPolylineFigure*>(group->getFigure(figureCounter));
			}

			std::vector<cFigure::Point> points;
			for (auto coord : coords)
			{
				points.push_back(cFigure::Point(coord.x, coord.y));
			}
			edgeFigure->setPoints(points);
			figureCounter++;
		}
	}

	for (int i = figureCounter; i < group->getNumFigures(); i++)
	{
		cFigure *figure = group->getFigure(figureCounter);
		group->removeFigure(figureCounter);
		delete figure;
	}
}

