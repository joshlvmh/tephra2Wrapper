from shapely.geometry import Polygon, mapping
import geopandas as gpd
'''
def linestring_to_polygon(fili_shps):
  gdf = gpd.read_file(fili_shps) #LINESTRING
  geom = [x for x in gdf.geometry]
  all_coords = mapping(geom[0])['coordinates']
  lats = [x[1] for x in all_coords]
  lons = [x[0] for x in all_coords]
  linestr = Polygon(zip(lons, lats))
  return gpd.GeoDataFrame(index=[0], crs=gdf.crs, geometry=[linestr])

poly_shapes = linestring_to_polygon("aoi/AOI_buff_500_km.shp")
#poly_shapes.to_file('shapefiles\BV_SJ_WGS84.shp')
poly_shapes.loc[:, 'geometry'].plot()
'''
import ogr

source_ds = ogr.Open("aoi/AOI_buff_500_km.shp")
source_layer = source_ds.GetLayer()
pixelWidth = pixelHeight = 0.001 
x_min, x_max, y_min, y_max = source_layer.GetExtent()
cols = int((x_max - x_min) / pixelHeight)
rows = int((y_max - y_min) / pixelWidth)
target_ds = gdal.GetDriverByName('GTiff').Create('temp.tif', cols, rows, 1, gdal.GDT_Byte) 
target_ds.SetGeoTransform((x_min, pixelWidth, 0, y_min, 0, pixelHeight))
band = target_ds.GetRasterBand(1)
NoData_value = 0
band.SetNoDataValue(NoData_value)
band.FlushCache()
gdal.RasterizeLayer(target_ds, [1], source_layer, options = ["ATTRIBUTE=AVG"])
target_ds = None #this is the line that makes the difference
gdal.Open('temp.tif').ReadAsArray()
