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

#ifndef DRONES_VEINS_PROJECT_VISUALIZERS_NODEOSGVISUALIZER_H_
#define DRONES_VEINS_PROJECT_VISUALIZERS_NODEOSGVISUALIZER_H_

#include "../drones_veins_project.h"
#include <omnetpp/cmodule.h>
#include "veins/veins.h"
#include "veins/base/utils/Coord.h"

#ifdef WITH_OSG
#include <osg/Geode>
#include <osg/MatrixTransform>
#endif

namespace drones_veins_project
{

	class NodeOsgVisualizer : public omnetpp::cModule, public cListener
	{
	public:
		NodeOsgVisualizer();
		virtual ~NodeOsgVisualizer();

		virtual void receiveSignal(cComponent* source, simsignal_t signalID, cObject* obj, cObject* details) override;

#ifdef WITH_OSG
	private:
		//static osg::Group* nodeVisualizerGroup;
		osg::ref_ptr<osg::MatrixTransform> osgTransform;
		osg::ref_ptr<osg::Geode> osgGeode;
public:
		virtual void initialize(int stage) override;

		virtual void initDrawables(osg::Vec4 colorVec);

		void setTransform(const veins::Coord& location, double angleZ);
#endif
	};

}

#endif /* DRONES_VEINS_PROJECT_VISUALIZERS_NODEOSGVISUALIZER_H_ */
