netgenerate --grid --grid.number 5 --output-file generated-grid.net.xml

./grid-generator-vs/grid_generator_vs.py generated-grid 5 5

netedit net.net.xml
