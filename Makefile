all: LATEST update-chart-descriptions

LATEST: \
	output/max_date.txt \
	output/carjacking-all-latest.csv \
	output/carjacking-ytd-latest.csv \
	output/dw-tables/carjacking-last-30-days.csv \
	output/dw-tables/carjacking-by-month-latest.csv \
	output/excel/carjacking-by-month-yoy-latest.xlsx \
	output/dw-tables/carjacking-by-month-yoy-latest.csv \
	output/dw-tables/carjacking-by-neighborhood-yoy-latest.csv \
	output/img/carjacking-by-month-yoy-latest.svg \
	output/img/carjacking-by-month-yoy-latest.png \
	README.md

.PHONY: \
	output/carjacking-all-latest-raw.csv \
	update-chart-descriptions

.INTERMEDIATE: \
	output/carjacking-all-latest-raw.csv

README.md: \
		src/update_readme.py \
		output/max_date.txt \
		output/excel/carjacking-by-month-yoy-latest.xlsx \
		output/img/carjacking-by-month-yoy-latest.png
	python $^ $@

output/dw-tables/carjacking-by-neighborhood-yoy-latest.csv: \
		src/dw_tables/carjacking_by_neighborhood_yoy.py \
		output/carjacking-ytd-latest.csv
	python $^ > $@

output/img/carjacking-by-month-yoy-latest.png: \
		src/img/carjacking_by_month_yoy.py \
		output/dw-tables/carjacking-by-month-yoy-latest.csv
	python $^ $@

output/img/carjacking-by-month-yoy-latest.svg: \
		src/img/carjacking_by_month_yoy.py \
		output/dw-tables/carjacking-by-month-yoy-latest.csv
	python $^ $@

output/dw-tables/carjacking-by-month-yoy-latest.csv: \
		src/dw_tables/carjacking_by_month_yoy.py \
		output/carjacking-ytd-latest.csv
	python $^ > $@

output/excel/carjacking-by-month-yoy-latest.xlsx: \
		src/excel/carjacking_by_month_yoy.py \
		output/carjacking-ytd-latest.csv
	python $^ $@

output/dw-tables/carjacking-by-month-latest.csv: \
		src/dw_tables/carjacking_by_month_latest.py \
		output/carjacking-all-latest.csv
	python $^ > $@

output/dw-tables/carjacking-last-30-days.csv: \
		src/dw_tables/carjacking_last_30_days.py \
		output/carjacking-all-latest.csv
	python $^ > $@

output/carjacking-ytd-latest.csv: \
		src/filter_ytd.py \
		output/carjacking-all-latest.csv
	python $^ > $@

output/carjacking-all-latest.csv: \
		src/merge_ca_name.py \
		output/carjacking-all-latest-raw.csv \
		input/boundaries-neighborhoods.geojson
	python $^ > $@

output/max_date.txt: \
		src/get_max_date.py \
		output/carjacking-all-latest-raw.csv
	python $^ $@

output/carjacking-all-latest-raw.csv:
	echo id,case_number,date,block,iucr,primary_type,description,location_description,arrest,domestic,beat,district,ward,community_area,fbi_code,x_coordinate,y_coordinate,year,updated_on,lat,lon,location > $@
	curl 'https://data.cityofchicago.org/resource/ijzp-q8t2.csv?$$query=SELECT%20*%20WHERE%20(iucr%20LIKE%20%270325%27%20OR%20iucr%20LIKE%20%270326%27)%20AND%20date%20%3E=%272015-01-01%27%20LIMIT%2010000000' | \
		awk "NR > 1" >> $@

update-chart-descriptions: \
		hand/chart-descriptions.json \
		output/max_date.txt
	python src/update_chart_descriptions.py $^
