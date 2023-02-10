UE_INSTALLATION_PATH="/home/dmitriy/Software/UnrealEngine5/"
RUNUAT_RELATIVE_PATH="Engine/Build/BatchFiles/RunUAT.sh"

RUN_UAT=$UE_INSTALLATION_PATH/$RUNUAT_RELATIVE_PATH

BUILD_PATH=$(realpath "./Obstacle3dDemo/Saved/StagedBuilds/Linux")
PROJ_PATH=$(realpath "./Obstacle3dDemo/Obstacle3dDemo.uproject")

$RUN_UAT -ScriptsForProject=$PROJ_PATH BuildCookRun -project=$PROJ_PATH -noP4 -clientconfig=Development -serverconfig=Development -nocompileeditor -installed -unrealexe=$UE_INSTALLATION_PATH/Engine/Binaries/Linux/UnrealEditor -utf8output -platform=Linux -build -cook -map=MainLevel+MainLevel -CookCultures=en -unversionedcookedcontent -stage -deploy -cmdline="MainLevel -Messaging"
