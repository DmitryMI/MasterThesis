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

#ifndef DRONES_VEINS_PROJECT_VISUALIZERS_ROADSOSGVISUALIZER2_H_
#define DRONES_VEINS_PROJECT_VISUALIZERS_ROADSOSGVISUALIZER2_H_

#include "veins/visualizer/roads/RoadsOsgVisualizer.h"

namespace drones_veins_project
{

	class RoadsOsgVisualizer2 : public veins::RoadsOsgVisualizer
	{
	private:
		bool flipY;

	public:
		RoadsOsgVisualizer2();
		virtual ~RoadsOsgVisualizer2();

		virtual void initialize(int stage) override;
	protected:
		virtual osg::Geode* createLine(const std::list<veins::Coord> &coords, cFigure::Color color, double width) override;
	};

}

#endif /* DRONES_VEINS_PROJECT_VISUALIZERS_ROADSOSGVISUALIZER2_H_ */
