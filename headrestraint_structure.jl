using Roots
using Unitful
using ArgParse
include("headrestraint_structure_formulas.jl")
function parseCli()
	s = ArgParseSettings(description ="Arguments passed by cli")
	@add_arg_table s begin
		"--Diameter"
			help = "Diameter in millimeters"
			required = true
		"--dratio"
			help = "This is the ratio between Major/Minor diameters"
			required = true
		"--yieldstrength"
			help = "Yield Strength in MPa"
			required = true
		"--fos"
			help = "Factor of Safety"
			required = true
	end
	return parse_args(s)
end
function design_structure(args)
	#F = F1 + F2
	#since F1 and F2 are equal distance from F
	# F1 = F2
	F = 890u"N" # Force for test.
	#fos is factor of safety.
	parsed_args = parseCli()
	fos = parse(Float16,parsed_args["fos"])
	println(fos)
	F1 = F * 0.5 * fos
	# M = F * L
	# M  = sigma / Z
	# Z = (pi * (D-d)^4)/ 64
	
	yield_stress = parse(Int16,parsed_args["yieldstrength"])
	yield_stress = yield_stress * 1u"MPa"
	sigma = u"N*m^-2"(yield_stress)
	Diameter = parse(Float32,parsed_args["Diameter"])
	Diameter = Diameter * 1u"mm"
	d_ratio = parse(Float32,parsed_args["dratio"])
	D = u"m"(Diameter)
	println(D)
	Z = section_modulus(D,d_ratio)
	#println("Section Modulus:$Z")
	println(Z)
	M = Moment(sigma,Z)
	L = M/F1
	#Established length to center of pressure is L
	#Height of headrest will be  L + 65  for clearance.
	L = u"mm"(L)
	headrest_height = L #+ 65u"mm"
	println("Length L,:$L")
	println("headrest_height:$headrest_height")
end
function design_structure_1(d_ratio,yield_stress,fos,breadth)
	#establish material_shear
	yield_stress = yield_stress * 1u"MPa"
	breadth = breadth * 1u"mm"
	F = 890u"N"
	F = F * fos
	sigma = u"N*m^-2"(yield_stress)
	b = u"m"(breadth)
	M  = F * b * 0.5 * 0.25
	Z = M/sigma
	section_modul(D) = ustrip(Z) - ((pi * (D^4-(d_ratio * D)^4))/(32 * D))
	upperlimit = 24
	D = fzero(section_modul,upperlimit)
	D = D * 1u"m"
	A = Area(D,d_ratio)
	t = shear(F,A)
	tau = u"MPa"(t)
	println("The shear stress:$tau")
	D = u"mm"(D)
	println("outer diameter:$D")
end
#design_structure(15,0.80,440,430,1.5)
#design_structure(15,0.80,440,430,1.5)
design_structure_1(0.0,420,1.0,170)
#design_structure(ARGS)