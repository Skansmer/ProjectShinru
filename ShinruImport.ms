-- Script made by nvlad
macroScript ShinruImp category:"ProjectShinru"
(
	fn ReadFixedString bstream fixedLen =
	(
		local str = ""
		for i = 1 to fixedLen do
		(
		-- str += bit.intAsChar (ReadByte bstream #unsigned)
		str0 = ReadByte bstream #unsigned
		if str0!=0xFF do str+=bit.intAsChar str0
		)
		str
	)

	clearlistener()
	Stream = getOpenFileName \
		caption:"Open Shinru models" \
		types:"All |*.*|Armor |*.amr|Pants |*.pnt|Guntlet |*.gtl|Shoes |*.sho|Helmet |*.hlm|Weapon |*.wpn|" \
		historyCategory:"KalOnline"
	s = fopen Stream "rb"

	--Print ("Starting at @ 0x"+((bit.intAsHex(ftell s))as string)) --Debug

	VerticesArr=#()
	FacesArr=#()
	UVs=#()	
	Normals=#()
		
	unk0 = readshort s
	unk1 = readshort s
	filename = ReadFixedString s 32
			
	iconNameLen = readlong s
	ItemDescLen = readlong s
			
	iconName = ReadFixedString s iconNameLen
	ItemDesc = ReadFixedString s ItemDescLen
			
	unk2 = readbyte s
	unk3 = readlong s
	TexCount = readlong s
	MeshCount = readlong s

	for i = 1 to TexCount do(
	TextureFile = ReadFixedString s 32
		
	x1 = readfloat s;y1 = readfloat s;z1 = readfloat s;w1 = readfloat s -- Some floats
	x2 = readfloat s;y2 = readfloat s;z2 = readfloat s;w2 = readfloat s -- Some floats
	x3 = readfloat s;y3 = readfloat s;z3 = readfloat s;w3 = readfloat s -- Some floats
		
	unk6 = ReadFixedString s 20
	)

	cMeshCount = 0
	if TexCount == 1 and MeshCount == 1 then(
		cMeshCount = MeshCount+1
	)else if TexCount < MeshCount then(
		cMeshCount = MeshCount+TexCount+1
	)else if TexCount == 2 and Meshcount == 2 then(
			cMeshCount = TexCount+MeshCount
	)else if TexCount == 2 and MeshCount == 1 do(
		cMeshCount = 1
	)

	for m = 1 to cMeshCount do(	
		MeshName = ReadFixedString s 64
			
		unk7 = ReadFixedString s 128 -- Some Colors or pixels
			
		unk8 = readlong s
		unk9 = readlong s
			
		VertexCount = readlong s #unsigned
		FaceCount = readlong s #unsigned

		for i = 1 to VertexCount do(
			vx = readfloat s
			vy = readfloat s
			vz = readfloat s
			
			n1 = readfloat s
			n2 = readfloat s
			n3 = readfloat s
			
			tu = readfloat s
			tv = readfloat s*-1
			
			append VerticesArr[vx,vy,-vz] 
			append UVs[tu,tv,0]
			append Normals[n1,n2,n3]
		)
			
		for x = 1 to FaceCount do(
			f1 = ((Readshort s) + 1) 
			f2 = ((Readshort s) + 1) 
			f3 = ((Readshort s) + 1) 
			append FacesArr [f3,f2,f1]
		)
		
		try(
			msh = mesh vertices:VerticesArr faces:FacesArr
			msh.numTVerts = UVs.count
			buildTVFaces msh
			for j = 1 to UVs.count do setTVert msh j UVs[j]
			for j = 1 to FacesArr.count do setTVFace msh j FacesArr[j]
									
			msh.name = MeshName
			convertTo msh PolyMeshObject
			rotate msh (angleaxis 90 [1,0,0])
		)catch()
		
		VerticesArr=#()
		FacesArr=#()
		UVs=#()
	)
	format "Filename: %\n" filename
	format "IconName: %\n---------------String---------------\n%\n------------------------------------\n" iconName ItemDesc
	format "TextureName: %\n" TextureFile
	format "Mesh: % - VC: %, FC: %\n" MeshName VertexCount FaceCount
	--Print ("Ended at @ 0x"+((bit.intAsHex(ftell s))as string)) --Debug
	fclose s -- Close Stream
)