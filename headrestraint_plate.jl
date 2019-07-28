using Roots
using Unitful
using ArgParse
function parseCli()
	s = ArgParseSettings(description ="Arguments passed by cli")
	@add_arg_table s begin
		"--width"
            help = "width/span in millimetres"
            arg_type = Int
            required = true
    
		"--yield_strength"
            help = "yield_strength of material"
            arg_type = Float64
			default = 63.0
		"--fos"
            help = "Factor of Safety"
            arg_type = Float64
			default = 1.4
	end
	return parse_args(s)
end
function design_plate(args)
    F = 890 * 1u"N"
    parsed_args = parseCli()
    fos = parsed_args["fos"]
    F1 = F * fos
    F1 = 0.5 * F1
    L = parsed_args["width"] * 1u"mm"
    L = u"m"(L)
    sigma_y = parsed_args["yield_strength"] * 1u"MPa"
    sigma_y = u"N*m^-2"(sigma_y)
    #Moment at center
    Moment(F,L) = (F*L)/4
    M = Moment(F1,L)
    constant1 = M/sigma_y
    constant1 = ustrip(constant1)
    Len = ustrip(L)
    f(thickness) = constant1 - ((Len*(thickness^2)) /6)
    curthickness = fzero(f,5e-3)
    curthickness = curthickness * 1u"m"
    curthickness = u"mm"(curthickness)
    println("curthickness:$curthickness")
end
design_plate(ARGS)
