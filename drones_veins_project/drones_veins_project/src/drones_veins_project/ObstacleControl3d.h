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

#ifndef DRONES_VEINS_PROJECT_OBSTACLECONTROL3D_H_
#define DRONES_VEINS_PROJECT_OBSTACLECONTROL3D_H_

#include "veins/modules/obstacle/ObstacleControl.h"
#include "Obstacle3d.h"

namespace drones_veins_project
{

	class ObstacleControl3d : public veins::ObstacleControl
	{
	protected:
		bool getHeightFromXml(cXMLElement* xml, std::string id, double& height);

	public:
		ObstacleControl3d();
		virtual ~ObstacleControl3d();

		virtual void initialize(int stage) override;

		virtual void add3d(Obstacle3d obstacle3d);
		virtual void add(veins::Obstacle obstacle) override;

		virtual void addFromXml(cXMLElement* xml) override;
		virtual void addFromTypeAndShape(std::string id, std::string typeId, std::vector<veins::Coord> shape) override;

		virtual std::vector<std::pair<veins::Obstacle*, std::vector<double>>> getIntersections(const veins::Coord& senderPos, const veins::Coord& receiverPos) const override;
	};
}
#endif /* DRONES_VEINS_PROJECT_OBSTACLECONTROL3D_H_ */
