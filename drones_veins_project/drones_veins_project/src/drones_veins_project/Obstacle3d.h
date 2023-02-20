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
		void getIntersectionPoints(const veins::Coord &lineStart, const veins::Coord &lineEnd,
				std::vector<veins::Coord> &outIntersections) const;
		bool getLineToLineIntersection(const veins::Coord &line1Start, const veins::Coord &line1End,
				const veins::Coord &line2Start, const veins::Coord &line2End, veins::Coord &outIntersection) const;
		bool getHorizonToLineIntersection(const veins::Coord &lineStart, const veins::Coord &lineEnd, float horizonY,
				veins::Coord &outIntersection) const;
		bool getHorizontalIntersection(const veins::Coord &lineStart, const veins::Coord &lineEnd, float intersectionZ,
				veins::Coord &intersectionPoint) const;

		bool getWallIntersection(const veins::Coord &lineStart, const veins::Coord &lineEnd, int wallStartIndex,
				int wallEndIndex, veins::Coord &intersectionPoint) const;
		void getWallIntersections(const veins::Coord &lineStart, const veins::Coord &lineEnd,
				std::vector<veins::Coord> &outIntersections) const;
#ifdef WITH_OSG
	private:
		osg::ref_ptr<osg::Group> osgNode;

		virtual osg::Geode* createWall(int wallIndex1, int wallIndex2, osg::PrimitiveSet::Mode mode, bool osgFlipY);
		virtual osg::Geode* createHorizontalPolygon(float height, osg::PrimitiveSet::Mode mode, bool osgFlipY);
		virtual void createOsgGeometry(const cFigure::Color &color, bool obstaclesShadingEnabled,
				bool wireframeModeEnabled, bool osgFlipY);
	public:
		virtual void drawOnOsgCanvas(cOsgCanvas *canvas, std::string &colorStr, bool obstaclesShadingEnabled,
				bool wireframeModeEnabled, bool osgFlipY);
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
	};
}

#endif /* DRONES_VEINS_PROJECT_OBSTACLE3D_H_ */
