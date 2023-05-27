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

#ifndef DRONES_VEINS_PROJECT_PATHFINDER_H_
#define DRONES_VEINS_PROJECT_PATHFINDER_H_

#include <string>
#include "../drones_veins_project.h"
#include "omnetpp.h"
#include "veins/base/utils/Coord.h"
#include "veins/modules/mobility/traci/TraCICoord.h"
#include <cmath>
#include "PathfinderEdge.h"
#include "PathfinderJunction.h"

namespace drones_veins_project
{

	class Pathfinder : public cSimpleModule
	{
	private:
		std::map<std::string, PathfinderEdge*> edges;
		std::map<std::string, PathfinderJunction*> junctions;

		static std::vector<std::string> parseEdgeList(const std::string& incLanes);

		static veins::TraCICoord parseCoord(const std::vector<std::string>& tokens);
		static std::vector<veins::TraCICoord> parseShape(const std::string& shapeStr);

		template<typename T>
		static bool vecContains(const std::vector<T>& vec, const T& item)
		{
			for (const T& vecItem : vec)
			{
				if (item == vecItem)
				{
					return true;
				}
			}

			return false;
		}


		PathfinderEdge* getNextRandomEdge(PathfinderEdge* currentEdge, const std::vector<std::string>& disallowedEdges) const;

	public:
		Pathfinder();
		virtual ~Pathfinder();

		virtual void initialize(int stage) override;
		virtual void finish() override;
		virtual int numInitStages() const override;

		std::list<PathfinderEdge*> generateRandomRoute(const std::string& startEdgeId, const std::vector<std::string>& disallowedEdges, double minDistance, uint64_t maxEdges = 1000) const;
		std::list<std::string> generateRandomRouteStr(const std::string& startEdgeId, const std::vector<std::string>& disallowedEdges, double minDistance, uint64_t maxEdges = 1000) const;
		std::list<std::string> generateRandomRouteStr(const std::string& startEdgeId, const std::set<std::string>& disallowedEdges, double minDistance, uint64_t maxEdges = 1000) const;
	};
}

#endif /* DRONES_VEINS_PROJECT_PATHFINDER_H_ */
