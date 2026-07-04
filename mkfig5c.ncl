; =====================================================================
; mkfig5c.ncl - 925hPa 风速填色 + 风羽 + 阳春上游区域框
; 绘制2026年5月18日21时（UTC）
; =============================================================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("add_line")
procedure add_line(wks,plot,x,y,plres)
local plres, str, y
begin
  str = unique_string("polyline")
  plot@$str$ = gsn_add_polyline(wks, plot, x, y, plres)
end

begin

;-------------------- 固定时次 --------------------
year  = "2026"
mon   = "05"
day   = "18"
hour  = 21
level = 925
;-------------------------------------------------

; 读ERA5数据（float格式，无需short2flt）
f  = addfile("/mnt/x/ERA5/ERA5_60N_50E_-10N_150E/2026/geopotential/" + "era5.geopotential." + year + mon + day + ".nc", "r")
f2 = addfile("/mnt/x/ERA5/ERA5_60N_50E_-10N_150E/2026/u_component_of_wind/" + "era5.u_component_of_wind." + year + mon + day + ".nc", "r")
f3 = addfile("/mnt/x/ERA5/ERA5_60N_50E_-10N_150E/2026/v_component_of_wind/" + "era5.v_component_of_wind." + year + mon + day + ".nc", "r")

wind_u   = f2->u(hour,{level},:,:)
wind_v   = f3->v(hour,{level},:,:)
uv_speed = wind_speed(wind_u, wind_v)

height = f->z(hour,{level},:,:)
hgt    = height / 98
lat    = f->latitude
lon    = f->longitude
copy_VarCoords(height, hgt)

;----------------------------------------------------------------------
png_name = "./figures/Figure5c"
wks = gsn_open_wks("eps", png_name)

;-- 风矢量 + 地图参数 -----------------------------------------------------------
resUV = True
resUV@gsnDraw       = False
resUV@gsnFrame      = False
resUV@gsnLeftString = ""

resUV@mpMinLatF = 10
resUV@mpMaxLatF = 35
resUV@mpMinLonF = 100.0
resUV@mpMaxLonF = 125.0

resUV@mpShapeMode = "FreeAspect"


resUV@vpWidthF    = 0.6
resUV@vpHeightF   = 0.4

resUV@mpOutlineOn                 = True
resUV@mpGeophysicalLineColor      = "gray"
resUV@mpGeophysicalLineThicknessF = 2.8
resUV@mpNationalLineColor         = "gray"
resUV@mpNationalLineThicknessF    = 5

resUV@mpFillOn              = False
resUV@mpDataBaseVersion     = "MediumRes"
resUV@mpDataSetName              = "./database/Earth..4"
resUV@mpProvincialLineThicknessF = 1.5
resUV@gsnAddCyclic          = False

; 坐标刻度
resUV@tmXTOn = False
resUV@tmYROn = False

resUV@tmXBMode = "Explicit"
resUV@tmXBValues = (/100,105,110,115,120,125/)
resUV@tmXBLabels = (/"100~S~o~N~E","105~S~o~N~E","110~S~o~N~E","115~S~o~N~E","120~S~o~N~E","125~S~o~N~E"/)
resUV@tmXBMajorLengthF        = 0.007
resUV@tmXBMajorOutwardLengthF = 0.007
resUV@tmXBMinorLengthF        = 0
resUV@tmXBLabelDeltaF         = -0.8
resUV@tmXBLabelFontHeightF    = 0.008

resUV@tmYLMode = "Explicit"
resUV@tmYLValues = (/10,15,20,25,30,35/)
resUV@tmYLLabels = (/"10~S~o~N~N","15~S~o~N~N","20~S~o~N~N","25~S~o~N~N","30~S~o~N~N","35~S~o~N~N"/)
resUV@tmYLLabelDeltaF      = -0.7
resUV@tmYLLabelFontHeightF = 0.008
resUV@tmYLMajorLengthF     = 0.007
resUV@tmYLMinorLengthF     = 0

; 风羽参数
resUV@vcMinDistanceF     = 0.023
resUV@vcMinMagnitudeF    = 1.0
resUV@vcPositionMode     = "ArrowTail"
resUV@vcLevelSpacingF    = 0.8
resUV@vcRefAnnoOn        = False
resUV@vcRefAnnoSide      = "Top"
resUV@vcRefAnnoBackgroundColor = -1
resUV@vcRefAnnoPerimOn   = False
resUV@vcRefMagnitudeF    = 4

resUV@vcGlyphStyle             = "WindBarb"
resUV@vcWindBarbScaleFactorF   = 2.5
resUV@vcWindBarbColor          = "blue"
resUV@vcGlyphOpacityF          = 0.7
resUV@vcWindBarbLineThicknessF = 4.8
resUV@vcRefLengthF             = 0.022

resUV@gsnMaximize       = True
resUV@vcVectorDrawOrder = "PostDraw"
resUV@gsnRightString = ""

; ========== 风速填色 ==========
resWS = True
resWS@gsnDraw        = False
resWS@gsnFrame       = False
resWS@gsnRightString = ""
resWS@gsnLeftString  = ""

resWS@cnLinesOn      = False
resWS@cnFillOn       = True
resWS@cnInfoLabelOn  = False
resWS@cnLineLabelsOn = False

resWS@cnLevelSelectionMode = "ExplicitLevels"
resWS@cnLevels             = (/8, 12, 16, 20, 24, 28, 32/)
resWS@cnFillPalette        = "precip3_16lev"
resWS@cnFillColors         = (/0, 2, 4, 6, 8, 10, 12, 14/)
resWS@cnFillOpacityF       = 0.9
resWS@cnFillDrawOrder      = "PreDraw"

resWS@tmYROn = False
resWS@tmXTOn = False

; 色标
resWS@lbLabelBarOn            = False

; ------------ 绘图 ------------
plotWS = gsn_csm_contour(wks, uv_speed, resWS)
plotUV = gsn_csm_vector_map(wks, wind_u, wind_v, resUV)

overlay(plotUV, plotWS)

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

plotprovince = gsn_add_shapefile_polylines(wks,plotUV,ShpDir+"province_10south.shp",provres) ; 有香港和澳门的界限
plotdiqu = gsn_add_shapefile_polylines(wks,plotUV,ShpDir+"china_polyline.shp",hkres)   ; 有广东和海南分界线

; 阳春上游区域框
plres                  = True
plres@gsLineColor      = "red"
plres@gsLineThicknessF = 7
plres@gsLineDashPattern = 1
add_line(wks, plotUV, (/110.5,110.5,113,113,110.5/), (/19.5,22,22,19.5,19.5/), plres)

resP                                  = True
resP@gsnFrame                         = False
resP@gsnPanelLabelBar                 = True
resP@lbOrientation                    = "Vertical"
resP@lbLabelFontColor                  = "black"
resP@pmLabelBarOrthogonalPosF          = 0.0075
resP@pmLabelBarWidthF                  = 0.05
resP@lbLabelFontHeightF                 = 0.08
resP@lbBoxLinesOn                      = True
resP@lbBoxLineThicknessF               = 0.9
resP@lbLabelFontHeightF               = 0.01
resP@gsnPanelFigureStringsFontHeightF = 0.02
resP@gsnPanelFigureStringsJust        = "TopLeft"
resP@gsnPanelFigureStrings            = (/"(c)"/)
resP@gsnPanelFigureStringsPerimOn     = False

gsn_panel(wks, plotUV, (/1,1/), resP)

frame(wks)

delete(wks)
system("convert -trim -density 600x600 " + png_name + ".eps " + png_name + ".jpg")

end
