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

#ifndef DRONES_VEINS_PROJECT_BASEAPPLICATIONLAYER_H_
#define DRONES_VEINS_PROJECT_BASEAPPLICATIONLAYER_H_

#include "veins/modules/application/ieee80211p/DemoBaseApplLayer.h"
#include "rebroadcasting/RebroadcastDecider.h"
#include "CarJammingAnnouncement_m.h"
#include "veins/base/utils/SimpleAddress.h"
#include <vector>

namespace drones_veins_project
{
	class BaseApplicationLayer : public veins::DemoBaseApplLayer
	{
	private:
		static veins::LAddress::L2Type addressCounter;

		int rebroadcastDeciderInGate;
		veins::LAddress::L2Type address;
		std::vector<double> latencies;

	protected:
		RebroadcastDecider* getRebroadcastDecider();

		virtual void onWSM(veins::BaseFrame1609_4 *wsm) override;
		virtual void onBSM(veins::DemoSafetyMessage* bsm) override;
		virtual void handleCarJammingAnnouncement(CarJammingAnnouncement* msg);
		virtual void handleSelfMsg(cMessage* msg) override;
		void setIconColor(std::string color);
		std::string getIconColor();

	public:
		BaseApplicationLayer();
		virtual ~BaseApplicationLayer();

		virtual void handleMessage(cMessage* msg) override;

		virtual void initialize(int stage) override;
		virtual void finish() override;

		int getRebroadcastDeciderInGate();

		veins::LAddress::L2Type getAddress();
	};

}

#endif /* DRONES_VEINS_PROJECT_BASEAPPLICATIONLAYER_H_ */
