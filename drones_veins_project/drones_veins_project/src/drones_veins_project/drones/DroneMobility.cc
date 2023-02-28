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

#include "DroneMobility.h"

using namespace drones_veins_project;

Define_Module(drones_veins_project::DroneMobility);

using namespace veins;

DroneMobility::DroneMobility()
{
	// TODO Auto-generated constructor stub

}

DroneMobility::~DroneMobility()
{
	// TODO Auto-generated destructor stub
}

void DroneMobility::initialize(int stage)
{
	BaseMobility::initialize(stage);

	EV_TRACE << "initializing DroneMobility stage " << stage << endl;

	if (stage == 0)
	{
		if (!isPreinitialized)
		{
			speed = par("speed").doubleValue();
			move.setSpeed(speed);
			angle = par("angle");
			angle = fmod(angle, 360);
			updateInterval = par("updateInterval");

			double initialHeightMin = par("initialHeightMin").doubleValue();
			double initialHeightMax = par("initialHeightMax").doubleValue();
			zCoord = uniform(initialHeightMin, initialHeightMax);
		}
	}
	else if (stage == 1)
	{
		stepTarget = move.getStartPos();
	}
}

void DroneMobility::fixIfHostGetsOutside()
{
	Coord dummy;
	//handleIfOutside(WRAP, stepTarget, dummy, dummy, angle);

	BorderHandling wo;

	Coord borderStep;
	wo = checkIfOutside(stepTarget, borderStep);

	EV << getParentModule()->getName() << " next mobility step: " << stepTarget;

	if (wo == NOWHERE)
	{
		return;
	}

	reflectIfOutside(wo, stepTarget, dummy, dummy, angle);

	Coord borderStart;
	goToBorder(REFLECT, wo, borderStep, borderStart);

	stepTarget.z = zCoord;

	move.setDirectionByTarget(stepTarget);

	move.setSpeed(borderStep.length() / updateInterval);
}

void DroneMobility::preInitialize(const Coord &position, simtime_t updateInterval)
{
	this->angle = par("angle").doubleValue();
	this->speed = par("speed").doubleValue();
	move.setSpeed(speed);
	this->updateInterval = updateInterval;

	this->setStartPosition(position);

	double initialHeightMin = par("initialHeightMin").doubleValue();
	double initialHeightMax = par("initialHeightMax").doubleValue();
	zCoord = uniform(initialHeightMin, initialHeightMax);

	isPreinitialized = true;
}

/**
 * Move the host if the destination is not reached yet. Otherwise
 * calculate a new random position
 */
void DroneMobility::moveDrone()
{
	move.setStart(stepTarget, simTime());

	double time = SIMTIME_DBL(updateInterval);

	stepTarget.x = (move.getStartPos().x + speed * cos(M_PI * angle / 180) * time);
	stepTarget.y = (move.getStartPos().y + speed * sin(M_PI * angle / 180) * time);
	stepTarget.z = zCoord;

	move.setSpeed(speed);
	move.setDirectionByTarget(stepTarget);

	fixIfHostGetsOutside();

	updatePosition();
}
