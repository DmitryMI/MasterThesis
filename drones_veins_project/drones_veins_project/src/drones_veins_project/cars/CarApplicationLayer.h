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

#ifndef DRONES_VEINS_PROJECT_CARAPPLICATIONLAYER_H_
#define DRONES_VEINS_PROJECT_CARAPPLICATIONLAYER_H_

#include "drones_veins_project/drones_veins_project.h"
#include "../BaseApplicationLayer.h"
#include "CarJammingDetector.h"
#include "../CarJammingAnnouncement_m.h"
#include <set>

namespace drones_veins_project
{

	class DRONES_VEINS_PROJECT_API CarApplicationLayer : public BaseApplicationLayer
	{
	private:
		CarJammingDetector jammingDetector;
		long messageSerialCounter = 0;
		std::set<veins::LAddress::L2Type> receivedJammingAnnouncements;
		double totalTimeInJam = 0.0;
		std::set<std::string> disallowedEdges;
		std::vector<double> latencies;
		std::vector<long> hops;

		mutable std::string lastShownRouteId = "";
		std::string currentRouteId = "";

		void onCarJammingStateChanged(bool jammed);
		void updateJammingDetector();

		std::string getCarDescriptor();
		virtual void handleCarJammingAnnouncement(CarJammingAnnouncement* msg) override;

		void changeRoute(cMessage* changeRouteMessage = nullptr);
	public:
		CarApplicationLayer();
		virtual ~CarApplicationLayer();

		virtual void initialize(int stage) override;
		virtual void finish() override;

	protected:
		virtual void onWSM(veins::BaseFrame1609_4 *wsm) override;
		virtual void onWSA(veins::DemoServiceAdvertisment *wsa) override;

		virtual void handleSelfMsg(cMessage *msg) override;
		virtual void handlePositionUpdate(cObject *obj) override;

		virtual void drawVehicleRoute() const;
		virtual void clearCanvasRouteFigures() const;
		virtual void refreshDisplay() const;


	};
}

#endif /* DRONES_VEINS_PROJECT_CARAPPLICATIONLAYER_H_ */
