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

#ifndef DRONES_VEINS_PROJECT_CARS_CARJAMMINGDETECTOR_H_
#define DRONES_VEINS_PROJECT_CARS_CARJAMMINGDETECTOR_H_

#include "drones_veins_project/drones_veins_project.h"
#include <functional>


using JammingStateChangesCallback = std::function<void(bool)>;

namespace drones_veins_project
{

	class DRONES_VEINS_PROJECT_API CarJammingDetector
	{
	private:
		omnetpp::simtime_t lastDrivingTimestamp;
		JammingStateChangesCallback jammingStateChangedCallback;

		bool jammingDetected = false;
		double minimalStandingDuration = 10;
		double lastUpdatedSpeed;
		void onJammingDetected();
		void onUnjammingDetected();
	public:
		CarJammingDetector(double minimalStandingSeconds);

		CarJammingDetector();

		void setCallback(JammingStateChangesCallback callback);
		void setMinimalStandingDuration(double seconds);
		double getMinimalStandingDuration();

		virtual ~CarJammingDetector();

		void updateJammingDetector(double currentSpeed);

		bool isJammedNow();
	};
}

#endif /* DRONES_VEINS_PROJECT_CARS_CARJAMMINGDETECTOR_H_ */
