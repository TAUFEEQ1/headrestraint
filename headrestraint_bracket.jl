using Roots
using Unitful
using ArgParse
function parseCli()
	s = ArgParseSettings(description ="Arguments passed by cli")
	@add_arg_table s begin
		# "--width"
		# 	help = "Diameter in millimeters"
		# 	required = true
		# "--height"
		# 	help = "This is the ratio between Major/Minor diameters"
		# 	required = true
		"--length"
			help = "length of column"
			required = true
		"--alength"
			help = "Area length of bracket"
			arg_type = Int
			default = 138
		"--awidth"
			help = "Area width of bracket"
			arg_type = Int
			default = 112
		"--aratio"
			help = "Area ratio"
			arg_type = Float64
			default = 0.80
		"--number_cols"
			help = "number of supporting columns"
			arg_type = Int
			default = 100
		"--poly_strength"
			help = "Polymer Strength"
			default = 80
		"--young_modulus"
			help = "young_modulus of material"
			default = 2.4
		"--fos"
			help = "Factor of Safety"
			default = 1.4
	end
	return parse_args(s)
end
function design_bracket(args)
    #F = F1 + F2
	#since F1 and F2 are equal distance from F
	# F1 = F2
	F = 890u"N" # Force for test.
	#fos is factor of safety.
	#adjusting for fos
	parsed_args = parseCli()
	F1 = F * parsed_args["fos"]
	
	awidth = parsed_args["awidth"] * 1u"mm"
	aheight = parsed_args["alength"] *1u"mm"
	area_face = awidth * aheight
	
	area_face = u"m^2"(area_face)
	println("Area Face:$area_face")

	# for fixed ends K = 0.5
	poly_stress = parsed_args["poly_strength"]
	sigma_c = poly_stress * 1u"MPa"
	sigma_c = u"N*m^-2"(sigma_c)
	no_columns = parsed_args["number_cols"]
	sigma_t = F1/area_face
	aratio = parsed_args["aratio"]
	stress_col = sigma_t * inv(aratio)

	young_modulus = parsed_args["young_modulus"]
	young_modulus = young_modulus * 1u"GPa"
	young_modulus = u"N*m^-2"(young_modulus)
	constant1 = 4 * (pi^2) * young_modulus *( 1/12)
	if sigma_c > stress_col
		f(beta) = stress_col - (constant1 * (beta^2))
		constant2 = fzero(f,0.4)
		length = parse(Int16,parsed_args["length"])
		length = length * 1u"mm"
		height = sqrt(constant2) * length
		println("The height of column is:$height")
		eff_area = area_face * aratio
		area_column = eff_area/no_columns
		area_column = u"mm^2"(area_column)
		width = area_column/length
		println("The width of column is:$width")
	else
		println("Stress is beyond compressive limit")
	end
end
design_bracket(ARGS)