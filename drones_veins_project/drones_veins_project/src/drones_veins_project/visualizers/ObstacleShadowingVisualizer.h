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

#ifndef DRONES_VEINS_PROJECT_VISUALIZERS_OBSTACLESHADOWINGVISUALIZER_H_
#define DRONES_VEINS_PROJECT_VISUALIZERS_OBSTACLESHADOWINGVISUALIZER_H_

#include <omnetpp/cmodule.h>
#include "veins/base/utils/Coord.h"
#include "veins/modules/obstacle/Obstacle.h"
#include <osg/StateSet>
#include <osg/Vec3>
#include <osg/Vec4>
#include <osg/Geode>
#include <osg/Group>
#include <vector>

namespace drones_veins_project
{

	class ObstacleShadowingVisualizer : public omnetpp::cSimpleModule
	{
	private:
		std::vector<osg::ref_ptr<osg::Group>> displayGroups;
		uint64_t displayGroupCounter = 0;
		bool osgFlipY;

	public:
		ObstacleShadowingVisualizer();
		virtual ~ObstacleShadowingVisualizer();

		virtual osg::ref_ptr<osg::StateSet> createLineStateSet(const osg::Vec4& color);
		virtual osg::ref_ptr<osg::StateSet> createShapeStateSet(const osg::Vec4& color);

		virtual osg::ref_ptr<osg::Geode> createLine(const osg::Vec3& from, const osg::Vec3& to);
		virtual osg::ref_ptr<osg::Geode> createSphere(const osg::Vec3& pos, double radius, osg::Vec4& colorVec);

		virtual void initialize(int stage) override;

		virtual void handleMessage(omnetpp::cMessage* msg) override;

		virtual void visualizeIntersections(
				const std::vector<std::pair<veins::Obstacle*, std::vector<double>>> &intersections,
				const veins::Coord &senderPos, const veins::Coord &receiverPos);
	};

}

#endif /* DRONES_VEINS_PROJECT_VISUALIZERS_OBSTACLESHADOWINGVISUALIZER_H_ */
