proj_name="generated-grid"
grid_size=5

netgenerate --grid --grid.number $grid_size --output-file $proj_name.net.xml

./grid-generator-vs/grid_generator_vs.py $proj_name $grid_size $grid_size

netedit -s $proj_name.net.xml -a $proj_name.poly.xml
