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

#include "../drones_veins_project.h"
#include "OsgManager.h"
#include "veins/base/utils/FindModule.h"
#include <veins/base/modules/BaseWorldUtility.h>

#ifdef WITH_OSG

#endif

using namespace drones_veins_project;

Define_Module(OsgManager);

OsgManager::OsgManager()
{
	// TODO Auto-generated constructor stub

}

OsgManager::~OsgManager()
{
	// TODO Auto-generated destructor stub
}

void OsgManager::initialize(int stage)
{
	cModule::initialize(stage);

#ifdef WITH_OSG

	if (stage != 0)
	{
		return;
	}

	cOsgCanvas *canvas = getParentModule()->getOsgCanvas();

	osg::Group *scene = dynamic_cast<osg::Group*>(canvas->getScene());
	if (!scene)
	{
		scene = new osg::Group();
		canvas->setScene(scene);
	}
	ASSERT(scene);

	globalLightSource = new osg::LightSource;
	osg::Light* globalLight = new osg::Light();
	globalLight->setLightNum(1);

	auto world = veins::FindModule<veins::BaseWorldUtility*>::findGlobalModule();

	const veins::Coord* playgroundSize = world->getPgs();

	double lightSourceHeight = par("lightSourceHeight").doubleValue();
	globalLight->setPosition(osg::Vec4(playgroundSize->x / 2, playgroundSize->y / 2, lightSourceHeight, 1));

	globalLight->setAmbient(osg::Vec4(1.0,1.0,1.0,1.0));
	globalLight->setDiffuse(osg::Vec4(1.0,1.0,1.0,1.0));
	globalLight->setSpecular(osg::Vec4(1,1,1,1));  // some examples don't have this one
	globalLight->setLinearAttenuation(0.01f);

	globalLightSource->setLight(globalLight);

	osg::ref_ptr<osg::StateSet> lightSS (scene->getOrCreateStateSet());

	globalLightSource->setLocalStateSetModes(osg::StateAttribute::ON);
	globalLightSource->setStateSetModes(*lightSS, osg::StateAttribute::ON);

	scene->addChild(globalLightSource);

#endif
}
