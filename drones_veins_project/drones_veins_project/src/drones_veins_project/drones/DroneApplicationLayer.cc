/*
 * DroneApplicationLayer.cpp
 *
 *  Created on: Jan 29, 2023
 *      Author: dmitriy
 */

#include "DroneApplicationLayer.h"

using namespace veins;
using namespace drones_veins_project;

Define_Module(drones_veins_project::DroneApplicationLayer);

DroneApplicationLayer::DroneApplicationLayer() {
	// TODO Auto-generated constructor stub

}

DroneApplicationLayer::~DroneApplicationLayer() {
	// TODO Auto-generated destructor stub
}

void DroneApplicationLayer::initialize(int stage)
{
	BaseApplicationLayer::initialize(stage);
}

void DroneApplicationLayer::onWSM(veins::BaseFrame1609_4 *wsm)
{
	BaseApplicationLayer::onWSM(wsm);
}

void DroneApplicationLayer::onWSA(veins::DemoServiceAdvertisment *wsa)
{
	// Never used
}

void DroneApplicationLayer::handleSelfMsg(cMessage *msg)
{
	BaseApplicationLayer::handleSelfMsg(msg);
}

void DroneApplicationLayer::handlePositionUpdate(cObject *obj)
{
	BaseApplicationLayer::handlePositionUpdate(obj);
}

