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

#include "RoadsOsgVisualizer2.h"
#include "veins/base/utils/FindModule.h"
#include "veins/base/modules/BaseWorldUtility.h"

using namespace drones_veins_project;

Define_Module(RoadsOsgVisualizer2);

RoadsOsgVisualizer2::RoadsOsgVisualizer2()
{
	// TODO Auto-generated constructor stub

}

RoadsOsgVisualizer2::~RoadsOsgVisualizer2()
{
	// TODO Auto-generated destructor stub
}

void RoadsOsgVisualizer2::initialize(int stage)
{
	if (stage == 0)
	{
		flipY = par("osgFlipY").boolValue();
	}

	RoadsOsgVisualizer::initialize(stage);
}

#ifdef WITH_OSG
osg::Geode* RoadsOsgVisualizer2::createLine(const std::list<veins::Coord> &coords, cFigure::Color color, double width)
{
	if (!flipY)
	{
		return RoadsOsgVisualizer::createLine(coords, color, width);
	}
	else
	{
		veins::BaseWorldUtility *world = veins::FindModule<veins::BaseWorldUtility*>::findGlobalModule();
		ASSERT(world);
		auto pgs = world->getPgs();
		std::list<veins::Coord> coordsFlipped;
		for (const veins::Coord &coord : coords)
		{
			veins::Coord flippedCoord = veins::Coord(coord.x, pgs->y - coord.y, coord.z);
			coordsFlipped.push_back(flippedCoord);
		}

		return RoadsOsgVisualizer::createLine(coordsFlipped, color, width);
	}
}
#endif
