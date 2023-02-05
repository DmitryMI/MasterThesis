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
#include "veins/modules/application/ieee80211p/DemoBaseApplLayer.h"
#include "CarJammingDetector.h"

namespace drones_veins_project
{

	class DRONES_VEINS_PROJECT_API CarApplicationLayer : public veins::DemoBaseApplLayer
	{
	private:
		CarJammingDetector jammingDetector;

		void onCarJammingStateChanged(bool jammed);
		void updateJammingDetector();

		std::string getCarDescriptor();

	public:
		CarApplicationLayer();
		virtual ~CarApplicationLayer();

		virtual void initialize(int stage) override;

	protected:
		virtual void onWSM(veins::BaseFrame1609_4 *wsm) override;
		virtual void onWSA(veins::DemoServiceAdvertisment *wsa) override;

		virtual void handleSelfMsg(cMessage *msg) override;
		virtual void handlePositionUpdate(cObject *obj) override;
	};
}

#endif /* DRONES_VEINS_PROJECT_CARAPPLICATIONLAYER_H_ */
