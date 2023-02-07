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

#ifndef REBROADCASTING_REBROADCASTDECIDER_H_
#define REBROADCASTING_REBROADCASTDECIDER_H_

#include "drones_veins_project/drones_veins_project.h"

namespace drones_veins_project
{

	class RebroadcastDecider : public cSimpleModule
	{
	private:
		int parentInGate;
	public:

		RebroadcastDecider();
		virtual ~RebroadcastDecider();

		virtual void initialize(int stage) override;
		virtual bool shouldRebroadcast();
		virtual void handleMessage(omnetpp::cMessage* msg) override;
		int getParentInGate();
	};

}

#endif /* REBROADCASTING_REBROADCASTDECIDER_H_ */
