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

#include "Obstacle3d.h"

using namespace veins;
using namespace drones_veins_project;

Obstacle3d::Obstacle3d(std::string id, std::string type, double attenuationPerCut, double attenuationPerMeter,
		double height) :
		Obstacle(id, type, attenuationPerCut, attenuationPerMeter)
{
	this->height = height;
}

Obstacle3d::~Obstacle3d()
{

}

bool Obstacle3d::containsPoint(veins::Coord Point) const
{
	// TODO Check Z
	return Obstacle::containsPoint(Point);
}

std::vector<double> Obstacle3d::getIntersections(const Coord& senderPos, const Coord& receiverPos) const
{
	// TODO Check z
	return Obstacle::getIntersections(senderPos, receiverPos);
}

