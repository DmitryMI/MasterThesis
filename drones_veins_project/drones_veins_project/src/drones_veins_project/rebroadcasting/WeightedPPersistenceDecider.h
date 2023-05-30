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

#ifndef DRONES_VEINS_PROJECT_REBROADCASTING_WEIGHTEDPPERSISTENCEDECIDER_H_
#define DRONES_VEINS_PROJECT_REBROADCASTING_WEIGHTEDPPERSISTENCEDECIDER_H_

#include "RebroadcastDecider.h"

namespace drones_veins_project
{
	class WeightedPPersistenceDecider : public RebroadcastDecider
	{
	private:
		double waitTime;
		double waitTimeDeviation;
		double deltaTime;
		double averageTransmissionRange;
		bool showBubbles = false;

		std::map<cMessage*, double> rebroadcastingQueue;
		std::map<cMessage*, cMessage*> dieOutBuffer;

	private:
		template<typename M, typename TContainer>
		M* getEqualMessageMap(cMessage *message, const TContainer &container)
		{
			M *messageInCast = dynamic_cast<M*>(message);
			ASSERT(messageInCast);
			veins::LAddress::L2Type senderAddressIn = messageInCast->getSenderAddress();
			long serialIn = messageInCast->getSerial();

			for (auto &item : container)
			{
				cMessage *msg = item.first;
				M *messageCast = dynamic_cast<M*>(msg);
				ASSERT(messageCast);
				veins::LAddress::L2Type senderAddress = messageCast->getSenderAddress();
				long serial = messageCast->getSerial();
				if (senderAddress == senderAddressIn && serialIn == serial)
				{
					return messageCast;
				}
			}

			return nullptr;
		}

		template<typename M, typename TContainer>
		M* getEqualMessage(cMessage *message, const TContainer &container)
		{
			M *messageInCast = dynamic_cast<M*>(message);
			ASSERT(messageInCast);
			veins::LAddress::L2Type senderAddressIn = messageInCast->getSenderAddress();
			long serialIn = messageInCast->getSerial();

			for (const auto &item : container)
			{
				cMessage *msg = item;
				M *messageCast = dynamic_cast<M*>(msg);
				ASSERT(messageCast);
				veins::LAddress::L2Type senderAddress = messageCast->getSenderAddress();
				long serial = messageCast->getSerial();
				if (senderAddress == senderAddressIn && serialIn == serial)
				{
					return messageCast;
				}
			}
			return nullptr;
		}



	protected:
		virtual void handleSelfMessage(omnetpp::cMessage *msg);

		void showBubble(const char* text);

	public:
		WeightedPPersistenceDecider();
		virtual ~WeightedPPersistenceDecider();

		virtual void initialize(int stage) override;
		virtual void handleMessage(omnetpp::cMessage *msg) override;
	};
}
#endif /* DRONES_VEINS_PROJECT_REBROADCASTING_WEIGHTEDPPERSISTENCEDECIDER_H_ */
