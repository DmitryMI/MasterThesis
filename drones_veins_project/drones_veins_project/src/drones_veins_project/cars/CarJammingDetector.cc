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

#include "CarJammingDetector.h"

using namespace drones_veins_project;
using namespace omnetpp;

CarJammingDetector::CarJammingDetector(double minimalSeconds)
{
	minimalStandingDuration = minimalSeconds;
}

CarJammingDetector::CarJammingDetector()
{
	minimalStandingDuration = 10.0;
}

void CarJammingDetector::setCallback(JammingStateChangesCallback callback)
{
	jammingStateChangedCallback = callback;
}

void CarJammingDetector::setMinimalStandingDuration(double seconds)
{
	minimalStandingDuration = seconds;
}

double CarJammingDetector::getMinimalStandingDuration()
{
	return minimalStandingDuration;
}


CarJammingDetector::~CarJammingDetector()
{

}

void CarJammingDetector::onJammingDetected()
{
	jammingStateChangedCallback(true);
}

void CarJammingDetector::onUnjammingDetected()
{
	jammingStateChangedCallback(false);
}

bool CarJammingDetector::isJammedNow()
{
	return lastUpdatedSpeed < 1 && simTime() - lastDrivingTimestamp >= minimalStandingDuration;
}

void CarJammingDetector::updateJammingDetector(double speed)
{
	lastUpdatedSpeed = speed;

	if(speed > 0)
	{
		lastDrivingTimestamp = simTime();
	}

	if (isJammedNow())
	{
		if (!jammingDetected)
		{
			onJammingDetected();
			jammingDetected = true;
		}
	}
	else
	{
		if (jammingDetected)
		{
			onUnjammingDetected();
			jammingDetected = false;
		}
	}
}

