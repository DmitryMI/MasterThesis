/*
 * DroneApplicationLayer.h
 *
 *  Created on: Jan 29, 2023
 *      Author: dmitriy
 */

#pragma once

#include "drones_veins_project/drones_veins_project.h"
#include "veins/modules/application/ieee80211p/DemoBaseApplLayer.h"

namespace drones_veins_project
{

	class DRONES_VEINS_PROJECT_API DroneApplicationLayer : public veins::DemoBaseApplLayer
	{
	public:
		DroneApplicationLayer();
		virtual ~DroneApplicationLayer();

		void initialize(int stage) override;

	protected:

	protected:
		void onWSM(veins::BaseFrame1609_4 *wsm) override;
		void onWSA(veins::DemoServiceAdvertisment *wsa) override;

		void handleSelfMsg(cMessage *msg) override;
		void handlePositionUpdate(cObject *obj) override;
	};

}
