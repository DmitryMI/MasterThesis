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

#include "VehicleCounter.h"
#include "veins/base/utils/FindModule.h"
#include "veins/modules/mobility/traci/TraCIVehicleInserter.h"

using namespace drones_veins_project;

Define_Module(drones_veins_project::VehicleCounter);

VehicleCounter::VehicleCounter() {
    // TODO Auto-generated constructor stub

}

VehicleCounter::~VehicleCounter() {
    // TODO Auto-generated destructor stub
}

VehicleCounter* VehicleCounter::instance = nullptr;


VehicleCounter* VehicleCounter::getInstance()
{
    return instance;
}

void VehicleCounter::incrementVehiclesSpawned()
{
    vehiclesSpawned++;
}

void VehicleCounter::incrementVehiclesDestroyed()
{
    vehiclesDestroyed++;

    auto sim = getSimulation();
    auto stage = sim->getSimulationStage();

    double seconds = simTime().dbl();
    EV << "Vehicle destroyed at simTime " << seconds << "s. SimStage is " << stage << "\n";


    ASSERT(sim->getSimulationStage() == CTX_FINISH);
    // sim->get
}

void VehicleCounter::initialize(int stage)
{
    instance = this;
    vehiclesSpawned = 0;
    vehiclesDestroyed = 0;
}

void VehicleCounter::finish()
{
    recordScalar("vehiclesSpawned", vehiclesSpawned);

    EV << "Vehicle Counter recorded " << vehiclesSpawned << " spawned vehicles.\n";

    veins::TraCIVehicleInserter* inserter = veins::FindModule<veins::TraCIVehicleInserter*>::findGlobalModule();
    int numVehicles = inserter->getNumVehicles();
    ASSERT(vehiclesSpawned == numVehicles);
    EV << "Simulation was configured to spawn " << numVehicles << " vehicles. Results consistent.\n";

}
