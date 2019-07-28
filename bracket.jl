using Roots
using Unitful
using ArgParse
function parseCli()
	s = ArgParseSettings(description ="Arguments passed by cli")
	@add_arg_table s begin
		"--length"
            help = "length of column"
            arg_type = Int
            required = true
        "--breadth"
            help = "breadth of support"
            arg_type = Int
            default = 170

		"--young_modulus"
			help = "young_modulus of material"
			default = 2.0
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
    F1 = 0.5 * F1

	# for fixed ends K = 0.5

    L = parsed_args["length"] * 1u"mm"
    L = u"m"(L)
    B = parsed_args["breadth"] * 1u"mm"
    B = u"m"(B)
	young_modulus = parsed_args["young_modulus"]
	young_modulus = young_modulus * 1u"GPa"
	young_modulus = u"N*m^-2"(young_modulus)
    constant1 = 4 * (pi^2) * young_modulus *( 1/12)
    constant1 = ustrip(constant1)
    breadth = ustrip(B)
    L = ustrip(L)
    constant3 = (constant1 * breadth) /(L^2)

    
    
    f(h) = ustrip(F1) - (constant3 * (h^3))
    constant2 = fzero(f,0.02)
    constant2 = constant2 * 1u"m"
    constant2 = u"mm"(constant2)
    println("Thickness of support column:$constant2")

    sigma_c = 80 *1u"MPa"
    sigma_c = u"N*m^-2"(sigma_c)
    Area = F1/sigma_c
    constant4 = Area/B
    println(constant4)
end
design_bracket(ARGS)