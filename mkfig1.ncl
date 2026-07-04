path = "./export_data/"

;-------------------------------------------------------------
res                            = True            
res@gsnDraw                    = False
res@gsnFrame                   = False
res@gsnPaperOrientation        = "Portrait"
;---------------------------------------------------------------
; Mask Guandong plot
;---------------------------------------------------------------
; set for the map 
res@mpMinLatF                  = 20
res@mpMaxLatF                  = 26
res@mpMinLonF                  = 109
res@mpMaxLonF                  = 118
   
res@mpFillOn                   = True                              ;所有底图填色
res@mpDataSetName              = "./database/Earth..4"
res@mpDataBaseVersion          = "MediumRes" ; or "Ncarg4_1"
res@mpLandFillColor            = "white"
res@mpOceanFillColor            = "white"
res@mpAreaMaskingOn            = True
res@mpMaskAreaSpecifiers       = (/"Guandong"/)
  
res@mpOutlineOn                = True
res@mpOutlineBoundarySets      = "AllBoundaries"

res@mpProvincialLineColor      = "gray"
res@mpProvincialLineThicknessF = 2.

res@mpGeophysicalLineColor     = "gray"
res@mpGeophysicalLineThicknessF = 2.

res@mpShapeMode                = "FreeAspect"
res@mpFillDrawOrder            = "draw"
res@mpOutlineDrawOrder         = "PostDraw"
;---------------------------------------------------------------
; set for the plot
res@cnFillOn                   = True
res@cnFillDrawOrder            = "PreDraw"
res@cnLinesOn                  = False            
res@gsnSpreadColors            = True   
res@lbLabelAutoStride          = True
res@pmTickMarkDisplayMode      = "Always"
res@gsnAddCyclic               = False
res@lbLabelBarOn               = False

res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels             = (/0.1,10,25,50,100,250,400,600,800,1000/)
res@cnFillColors         = ispan(2, 11, 1)
res@cnLineLabelsOn       = False

res@vpHeightF               = 0.5
res@vpWidthF                = 0.7
;-------------------------------------------------------------
;--- add shp file boundaries to test whether the border overlap---
  ShpDir = "./cnmap/"
  cnres                       = True
  cnres@gsLineThicknessF      = 2.
  cnres@gsLineColor           = "gray"

  ; 省界（广东-海南分界线）
  provres                     = True
  provres@gsLineThicknessF    = 2.
  provres@gsLineColor         = "gray"
  provres@minlon              = 109
  provres@maxlon              = 118
  provres@minlat              = 20
  provres@maxlat              = 26

  ; 香港、澳门地区界
  hkres                       = True
  hkres@gsLineThicknessF      = 2.
  hkres@gsLineColor           = "gray"
  hkres@gsLineDashPattern     = 2    ; 虚线
  hkres@minlon                = 109
  hkres@maxlon                = 118
  hkres@minlat                = 20
  hkres@maxlat                = 26
;------------------------------------------------------------- 
data_base := asciiread(path+"fig1a_cumulative.txt", -1, "string")
lon := stringtofloat(str_get_field(data_base(1:), 2, " "))
lat := stringtofloat(str_get_field(data_base(1:), 3, " "))
tp  := stringtofloat(str_get_field(data_base(1:), 4, " "))

tp@_FillValue = 9999

Rain1 = obj_anal_ic_Wrap(lon, lat, tp, fspan(109.6, 117.4, 157), \
                                 fspan(20.1, 25.5, 109), (/0.1,0.01,0.001/), False)

data_base := asciiread(path+"fig1b_max24h.txt", -1, "string")
lon := stringtofloat(str_get_field(data_base(1:), 2, " "))
lat := stringtofloat(str_get_field(data_base(1:), 3, " "))
tp  := stringtofloat(str_get_field(data_base(1:), 4, " "))

tp@_FillValue = 9999

Rain2 = obj_anal_ic_Wrap(lon, lat, tp, fspan(109.6, 117.4, 157), \
                                 fspan(20.1, 25.5, 109), (/0.1,0.01,0.001/), False)

data_base := asciiread(path+"fig1c_max12h.txt", -1, "string")
lon := stringtofloat(str_get_field(data_base(1:), 2, " "))
lat := stringtofloat(str_get_field(data_base(1:), 3, " "))
tp  := stringtofloat(str_get_field(data_base(1:), 4, " "))

tp@_FillValue = 9999

Rain3 = obj_anal_ic_Wrap(lon, lat, tp, fspan(109.6, 117.4, 157), \
                                 fspan(20.1, 25.5, 109), (/0.1,0.01,0.001/), False)

dim1 = dimsizes(Rain1(:,0))
dim2 = dimsizes(Rain1(0,:))
all_rain = new( (/3,dim1,dim2/), typeof(Rain1), getFillValue(Rain1) )

all_rain(0,:,:) = Rain1
all_rain(1,:,:) = Rain2
all_rain(2,:,:) = Rain3

delete([/Rain1,Rain2,Rain3/])

outdir = "./figures/"
system("mkdir -p "+outdir)
outfigure = outdir+"Figure1"
wks = gsn_open_wks("eps", outfigure)
color_map = RGBtoCmap("10colors-process.rgb")
gsn_define_colormap(wks, color_map)

all_rain!1 = "lat"
all_rain!2 = "lon"
all_rain&lat@units = "degrees_north"
all_rain&lon@units = "degrees_east"

poisson_grid_fill(all_rain, False, 1, 100, 1.e-2, 0.6, 0)

system("mkdir -p "+"./figures/")
LST = (/"(a)","(b)","(c)"/)
CST = (/"Accumulated rainfall","The maximum 24-hour rainfall","The maximum 12-hour rainfall"/)


plot = new( 3, "graphic" )
plotshp = new( 3, "graphic" )
plotprovince = new( 3, "graphic" )
plotdiqu = new( 3, "graphic" )

do iplot = 0, 3-1
  ; res@gsnCenterString         = ""+CST(iplot)
  ; res@gsnLeftString           = ""+LST(iplot)
  plot(iplot) = gsn_csm_contour_map(wks, all_rain(iplot,:,:), res)
  plotshp(iplot) = gsn_add_shapefile_polylines(wks,plot(iplot),ShpDir+"guangdong_city_polyline.shp",cnres)  ; 广东省内市的界限
  plotprovince(iplot) = gsn_add_shapefile_polylines(wks,plot(iplot),ShpDir+"province_10south.shp",provres) ; 有香港和澳门的界限
  plotdiqu(iplot) = gsn_add_shapefile_polylines(wks,plot(iplot),ShpDir+"china_polyline.shp",hkres)   ; 有广东和海南分界线
end do

resP                                  = True
resP@gsnFrame                         = False
resP@gsnPanelLabelBar                 = True
resP@lbOrientation                    = "Horizontal"
resP@lbLabelFontHeightF               = 0.01
resP@gsnPanelFigureStringsFontHeightF = 0.01
resP@gsnPanelFigureStringsJust        = "TopLeft"
resP@gsnPanelFigureStrings            = (/"(a)","(b)","(c)"/)
resP@gsnPanelFigureStringsPerimOn     = False
resP@lbTitleString                    = "mm"
resP@lbTitleFontHeightF               = 0.0125
resP@pmLabelBarOrthogonalPosF         = -0.0125
resP@lbTitleJust                      = "TopRight"

gsn_panel(wks, plot, (/1,3/), resP)

frame(wks)

delete(wks)

system("convert -trim -density 600x600 "+outfigure+".eps "+outfigure+".jpg")