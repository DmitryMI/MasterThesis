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

#ifndef DRONES_VEINS_PROJECT_OBSTACLE3D_H_
#define DRONES_VEINS_PROJECT_OBSTACLE3D_H_

#include "drones_veins_project.h"
#include "veins/modules/obstacle/Obstacle.h"

#ifdef WITH_OSG
#include <osg/Geode>
#include <osg/Geometry>
#include <osg/Group>
#include <osg/LineWidth>
#include <osg/Material>
#include <osg/ShapeDrawable>
#include <osg/Matrix>
#include <osg/MatrixTransform>
#endif

namespace drones_veins_project
{

	class Obstacle3d : public veins::Obstacle
	{
	private:
#ifdef WITH_OSG
		osg::ref_ptr<osg::Group> osgNode;

		virtual osg::Geode* createWall(int wallIndex1, int wallIndex2);
		virtual osg::Geode* createHorizontalPolygon(float height);
		virtual void createOsgGeometry(const cFigure::Color& color);
#endif

	protected:
		double height;
	public:
		Obstacle3d(std::string id, std::string type, double attenuationPerCut, double attenuationPerMeter,
				double height);
		virtual ~Obstacle3d();

		virtual bool containsPoint(veins::Coord Point) const override;
		virtual std::vector<double> getIntersections(const veins::Coord &senderPos,
				const veins::Coord &receiverPos) const override;

		virtual void drawOnOsgCanvas(cOsgCanvas *canvas, std::string& colorStr);
	};
}

#endif /* DRONES_VEINS_PROJECT_OBSTACLE3D_H_ */
