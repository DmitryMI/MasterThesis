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

#include "DroneManager.h"
#include "DroneMobility.h"
#include "veins/base/utils/FindModule.h"

using namespace drones_veins_project;
using namespace omnetpp;
using namespace veins;

Define_Module(drones_veins_project::DroneManager);

DroneManager::DroneManager()
{
	// TODO Auto-generated constructor stub

}

DroneManager::~DroneManager()
{
	if (spawnDronesTrigger)
	{
		cancelAndDelete(spawnDronesTrigger);
		spawnDronesTrigger = nullptr;
	}
	if (updateDronesMobilityTrigger)
	{
		cancelAndDelete(updateDronesMobilityTrigger);
		updateDronesMobilityTrigger = nullptr;
	}
}

void DroneManager::initialize()
{
	world = FindModule<BaseWorldUtility*>::findGlobalModule();

	scheduleAt(simTime() + par("updateInterval").doubleValue(), spawnDronesTrigger);
}

void DroneManager::handleMessage(cMessage *msg)
{
	const char *msgName = msg->getName();
	std::string msgNameStr(msgName);
	if (msgNameStr == "SpawnDronesTrigger")
	{
		spawnDrones();
		scheduleAt(simTime() + par("updateInterval").doubleValue(), updateDronesMobilityTrigger);
	}
	else if (msgNameStr == "UpdateDronesMobilityTrigger")
	{
		updateDronesMobility();
		scheduleAt(simTime() + par("updateInterval").doubleValue(), updateDronesMobilityTrigger);
	}
}

void DroneManager::updateDronesMobility()
{
	for (cModule *drone : drones)
	{
		updateModuleMobility(drone);
	}
}

void DroneManager::updateModuleMobility(cModule *module)
{
	auto mobilityModules = veins::getSubmodulesOfType<DroneMobility>(module);
	for (auto mm : mobilityModules)
	{
		mm->moveDrone();
	}
}

cModule* DroneManager::createModule(std::string name, std::string type, size_t nodeVectorIndex)
{
	cModule *parentmod = getParentModule();
	if (!parentmod)
		throw cRuntimeError("Parent Module not found");

	cModuleType *nodeType = cModuleType::get(type.c_str());
	if (!nodeType)
		throw cRuntimeError("Module Type \"%s\" not found", type.c_str());

#if OMNETPP_BUILDNUM >= 1525
    parentmod->setSubmoduleVectorSize(name.c_str(), nodeVectorIndex + 1);
    cModule* mod = nodeType->create(name.c_str(), parentmod, nodeVectorIndex);
#else
	cModule *mod = nodeType->create(name.c_str(), parentmod, nodeVectorIndex, nodeVectorIndex);
#endif

	return mod;
}

void DroneManager::spawnDrones()
{
	// TODO Read from simulation parameters
	int numberOfDrones = par("numberOfDrones").intValue();

	for (int i = 0; i < numberOfDrones; i++)
	{
		Coord randomPosition = world->getRandomPosition();
		spawnDrone(randomPosition);
	}
}

void DroneManager::spawnDrone(const Coord &position)
{
	std::string moduleTypes = par("moduleType").stdstringValue();
	std::string moduleNames = par("moduleName").stdstringValue();
	std::string moduleDisplayStrings = par("moduleDisplayString").stdstringValue();

	cModule *drone = createModule(moduleNames, moduleTypes, drones.size());

	drone->finalizeParameters();
	if (moduleDisplayStrings.length() > 0)
	{
		drone->getDisplayString().parse(moduleDisplayStrings.c_str());
	}

	drone->buildInside();

	double updateInterval = par("updateInterval").doubleValue();
	drone->scheduleStart(simTime() + updateInterval);

	auto mobilityModules = veins::getSubmodulesOfType<DroneMobility>(drone);
	for (auto mm : mobilityModules)
	{
		mm->preInitialize(position, updateInterval);
	}

	drone->callInitialize();

	drones.push_back(drone);

	updateModuleMobility(drone);
}
