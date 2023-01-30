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

#ifndef DRONES_VEINS_PROJECT_DRONES_DRONEMOBILITY_H_
#define DRONES_VEINS_PROJECT_DRONES_DRONEMOBILITY_H_

#include "veins/base/modules/BaseMobility.h"

namespace drones_veins_project
{

    class DroneMobility : public veins::BaseMobility
    {
    private:
    	double speed;
        double angle;
        double zCoord;
        veins::Coord stepTarget;
        simtime_t updateInterval;

        bool isPreinitialized = false;

    protected:
        void fixIfHostGetsOutside() override;

    public:
        DroneMobility();
        virtual ~DroneMobility();

        void initialize(int) override;

        void preInitialize(const veins::Coord& position, simtime_t updateInterval);

        void moveDrone();
    };
}
#endif /* DRONES_VEINS_PROJECT_DRONES_DRONEMOBILITY_H_ */
