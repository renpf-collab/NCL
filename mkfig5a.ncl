; =====================================================================
; mkfig5a.ncl - 200hPa位势高度 + 散度填色 + 风矢量
; 绘制2026年5月19日09时（UTC）
; =============================================================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;-------------------- 固定时次 --------------------
year  = "2026"
mon   = "05"
day   = "19"
hour  = 9
level = 200
;-------------------------------------------------

; 读ERA5数据
f  = addfile("/mnt/x/ERA5/ERA5_60N_50E_-10N_150E/2026/geopotential/" + "era5.geopotential." + year + mon + day + ".nc", "r")
f2 = addfile("/mnt/x/ERA5/ERA5_60N_50E_-10N_150E/2026/u_component_of_wind/" + "era5.u_component_of_wind." + year + mon + day + ".nc", "r")
f3 = addfile("/mnt/x/ERA5/ERA5_60N_50E_-10N_150E/2026/v_component_of_wind/" + "era5.v_component_of_wind." + year + mon + day + ".nc", "r")

u1 = f2->u(hour,{level},:,:)
v1 = f3->v(hour,{level},:,:)
wind_u =  u1 
wind_v = v1
uv_speed = wind_speed(u1, v1)

height = f->z(hour,{level},:,:)
hgt = height / 98
copy_VarCoords(height, hgt)

lat = f->latitude
lon = f->longitude

;----------------------------------------------------------------------
png_name = "./figures/Figure5a"
wks = gsn_open_wks("eps", png_name)

;-- 地图参数 ----------------------------------------------------------------
res = True
res@gsnDraw = False
res@gsnFrame = False

res@mpMinLatF          = 10.0
res@mpMaxLatF          = 30.0
res@mpMinLonF          = 95.0
res@mpMaxLonF          = 125.0
  
res@mpFillOn           = False
res@mpProjection       = "LambertEqualArea"
res@mpLimitMode        = "LatLon"
res@mpCenterLatF       = (res@mpMinLatF+res@mpMaxLatF)/2.
res@mpCenterLonF       = (res@mpMinLonF+res@mpMaxLonF)/2.

res@vpWidthF           = 0.6
res@vpHeightF          = 0.4

res@mpDataBaseVersion           = "MediumRes"
res@mpDataSetName               = "./Earth..4"

res@mpOutlineOn                 = True
res@mpGeophysicalLineColor      = "gray"
res@mpGeophysicalLineThicknessF = 1.8
res@mpNationalLineColor         = "gray"
res@mpNationalLineThicknessF    = 3.5


res@mpProvincialLineThicknessF = 1.5
res@gsnAddCyclic               = False

; 下标题
res@tiXAxisFontHeightF  = 0.012
res@tiXAxisFontColor    = "black"
res@tiXAxisOffsetYF     = 0
res@tiXAxisOffsetXF     = -0.25

; 坐标刻度
res@tmXTOn              = False
res@tmYROn              = False
res@pmTickMarkDisplayMode = "Always"

res@tmXBMajorLengthF        = 0.008
res@tmXBMajorOutwardLengthF = 0.008
res@tmXBMajorThicknessF     = 3
res@tmXBMinorLengthF        = 0
res@tmXBLabelDeltaF         = -0.6
res@tmXBLabelFontHeightF    = 0.011

res@tmYLLabelDeltaF      = -0.7
res@tmYLLabelFontHeightF = 0.011
res@tmYLMajorLengthF     = 0.008
res@tmYLMinorLengthF     = 0
res@tmYLMajorThicknessF  = 3

; 等值线
res@cnLinesOn          = False
res@cnLineDashPattern   = 0
res@cnLineColor         = "black"
res@cnLineThicknessF    = 3.0
res@cnLineLabelsOn      = False
res@cnLabelDrawOrder    = "PostDraw"
res@cnLineLabelFontHeightF = 0.0090
res@cnLineLabelBackgroundColor = "white"
res@cnLabelDrawOrder    = "PostDraw"
res@cnLineDrawOrder     = "Postdraw"
res@cnInfoLabelOn       = False

; 散度填色
res@cnFillOn            = True
sandu = uv2dv_cfd(wind_u, wind_v, lat, lon, 2) * 100000
copy_VarCoords(height, sandu)

res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels             = (/0, 2, 4, 6, 8, 10/)
res@cnFillPalette        = "precip3_16lev"
res@cnFillColors         = (/0, 2, 4, 10, 13, 15, 16/)
res@cnFillDrawOrder      = "PreDraw"
res@cnFillOpacityF       = 0.9

res@lbLabelBarOn = False


; ------------ 散度填色图 -------------
plot = gsn_csm_contour_map(wks, sandu, res)

; ==================== 200hPa风矢量 ====================
resUV                             = True
resUV@gsnLeftString               = ""
resUV@gsnRightString              = ""
resUV@gsnDraw                     = False
resUV@gsnFrame                    = False

resUV@vcMinDistanceF              = 0.026
resUV@vcMinMagnitudeF             = 1.0
resUV@vcPositionMode              = "ArrowTail"
resUV@vcLevelSpacingF             = 1.5

resUV@vcRefAnnoOn                 = False
resUV@vcRefAnnoSide               = "Top"
resUV@vcRefAnnoBackgroundColor    = -1
resUV@vcRefAnnoPerimOn            = False
resUV@vcRefMagnitudeF             = 4

resUV@vcGlyphStyle                = "CurlyVector"
resUV@vcLineArrowColor            = "black"
resUV@vcLineArrowThicknessF       = 2.6

resUV@vcWindBarbScaleFactorF      = 2.5
resUV@vcWindBarbColor             = "blue"
resUV@vcWindBarbLineThicknessF    = 3.5
resUV@vcRefLengthF                = 0.020

resUV@vcGlyphOpacityF   = 0.7
resUV@gsnMaximize       = True
resUV@vcVectorDrawOrder = "PreDraw"

wrf_smooth_2d(uv_speed, 10)
plotUV = gsn_csm_vector(wks, wind_u, wind_v, resUV)

; 叠加
overlay(plot, plotUV)

ShpDir = "./cnmap/"

; 省界（广东-海南分界线）
  provres                     = True
  provres@gsLineThicknessF    = 1.5
  provres@gsLineColor         = "gray"
  provres@minlon              = 109
  provres@maxlon              = 118
  provres@minlat              = 20
  provres@maxlat              = 26

  ; 香港、澳门地区界
  hkres                       = True
  hkres@gsLineThicknessF      = 1.5
  hkres@gsLineColor           = "gray"
  hkres@gsLineDashPattern     = 2    ; 虚线
  hkres@minlon                = 109
  hkres@maxlon                = 118
  hkres@minlat                = 20
  hkres@maxlat                = 26

plotprovince = gsn_add_shapefile_polylines(wks,plot,ShpDir+"province_10south.shp",provres) ; 有香港和澳门的界限
plotdiqu = gsn_add_shapefile_polylines(wks,plot,ShpDir+"china_polyline.shp",hkres)   ; 有广东和海南分界线


resP                                  = True
resP@gsnFrame                         = False
resP@gsnPanelLabelBar                 = True
resP@lbOrientation                    = "Vertical"
resP@lbLabelFontColor                  = "black"
resP@pmLabelBarOrthogonalPosF          = 0.0125
resP@pmLabelBarWidthF                  = 0.05
resP@lbLabelFontHeightF                 = 0.08
resP@lbBoxLinesOn                      = True
resP@lbBoxLineThicknessF               = 0.9
resP@lbLabelFontHeightF               = 0.01
resP@gsnPanelFigureStringsFontHeightF = 0.02
resP@gsnPanelFigureStringsJust        = "TopLeft"
resP@gsnPanelFigureStrings            = (/"(a)"/)
resP@gsnPanelFigureStringsPerimOn     = False

gsn_panel(wks, plot, (/1,1/), resP)


frame(wks)

delete(wks)
system("convert -trim -density 600x600 " + png_name + ".eps " + png_name + ".jpg")

end
