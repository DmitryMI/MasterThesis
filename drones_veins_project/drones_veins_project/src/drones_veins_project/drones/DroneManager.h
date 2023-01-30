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

#ifndef DRONES_VEINS_PROJECT_DRONES_DRONEMANAGER_H_
#define DRONES_VEINS_PROJECT_DRONES_DRONEMANAGER_H_

#include <vector>
#include <omnetpp.h>
#include <omnetpp/csimplemodule.h>
#include <veins/base/modules/BaseWorldUtility.h>

namespace drones_veins_project
{
    class DroneManager : public omnetpp::cSimpleModule
    {
    private:
    	veins::BaseWorldUtility* world;

        std::vector<cModule*> drones;
        omnetpp::cMessage* spawnDronesTrigger = new omnetpp::cMessage("SpawnDronesTrigger");
        omnetpp::cMessage* updateDronesMobilityTrigger = new omnetpp::cMessage("UpdateDronesMobilityTrigger");

        void updateModuleMobility(cModule *module);

        omnetpp::cModule* createModule(std::string name, std::string type, size_t nodeVectorIndex);

        void spawnDrone(const veins::Coord& position);
        void spawnDrones();
        void updateDronesMobility();

    public:

        virtual void initialize() override;
        virtual void handleMessage(omnetpp::cMessage *msg) override;

        DroneManager();
        virtual ~DroneManager();
    };
}

#endif /* DRONES_VEINS_PROJECT_DRONES_DRONEMANAGER_H_ */
