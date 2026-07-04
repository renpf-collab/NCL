# mkfig_guangdong_rainfall_map.ncl

## 功能概述

绘制广东省2026年5月一次暴雨过程的累计降雨量及最大逐时降雨量空间分布图（1行3列panel图）。

## 输出文件

- `figures/Figure1.eps` — 矢量图
- `figures/Figure1.jpg` — 600dpi JPG

## 三个子图

| 子图 | 数据文件 | 内容 |
|---|---|---|
| (a) | `export_data/fig1a_cumulative.txt` | 过程累计降雨量 |
| (b) | `export_data/fig1b_max24h.txt` | 最大24小时降雨量 |
| (c) | `export_data/fig1c_max12h.txt` | 最大12小时降雨量 |

## 数据流程

1. 从 `export_data/` 读取站点经纬度和降雨量（ASCII文本）
2. 通过 `obj_anal_ic_Wrap` 进行 Cressman 客观分析插值到网格（157×109）
3. `poisson_grid_fill` 对缺省值做泊松填充
4. `gsn_csm_contour_map` 绘制填色图

## 地图叠加层

| 图层 | shapefile | 内容 |
|---|---|---|
| 城市边界 | `guangdong_city_polyline.shp` | 广东省内地级市界 |
| 省级边界 | `province_10south.shp` | 华南省界（含香港、澳门） |
| 国界/海岸线 | `china_polyline.shp` | 全国边界（含广东-海南海上分界线） |

## 色标

- 使用自定义色标文件 `10colors-process.rgb`
- 降雨量分级（mm）：0.1, 10, 25, 50, 100, 250, 400, 600, 800, 1000

## 地图设置

- 区域：20-26°N, 109-118°E（广东省及周边）
- 底图：Earth..4 MediumRes，仅显示广东省
- 省界/国界/海岸线：灰色

## 运行方式

```bash
ncl mkfig1_rainfall.ncl
```

## 依赖

- NCL 6.4+
- Earth..4 地图数据库（`./database/Earth..4`）
- cnmap shapefile 组（`./cnmap/`）
- 自定义色标（`10colors-process.rgb`）
- ImageMagick（`convert` 命令，EPS→JPG转换）
