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

#ifndef DRONES_VEINS_PROJECT_VISUALIZERS_OSGMANAGER_H_
#define DRONES_VEINS_PROJECT_VISUALIZERS_OSGMANAGER_H_

#include <omnetpp/cmodule.h>

#ifdef WITH_OSG
#include <osg/Light>
#include <osg/LightSource>
#include <osg/Group>
#endif

namespace drones_veins_project
{

	class OsgManager : public omnetpp::cModule
	{
	private:
		osg::ref_ptr<osg::LightSource> globalLightSource;
		osg::ref_ptr<osg::Light> globalLight;
	public:
		OsgManager();
		virtual ~OsgManager();

		virtual void initialize(int stage) override;
	};

}

#endif /* DRONES_VEINS_PROJECT_VISUALIZERS_OSGMANAGER_H_ */
