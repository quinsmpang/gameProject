#coding=gbk


def generate(input_dir, output_dir, output_name, ext, spacing, max_size, coding):
    import os
    try:
        from PIL import Image
    except ImportError:
        import Image

    if not output_dir:
    	output_dir = input_dir
    	
    unis = [(0x20, {
        'id': 0x20,
        'path': '',
        #'x':x, 'y':y,
        'w':1, 'h':1,
    })]

    for f in os.listdir(input_dir):
        code = None
        path = os.path.join(input_dir, f)
        if os.path.isfile(path):
            tmp = os.path.splitext(f)
            if tmp[1].lower() == ext:
                uni = tmp[0].decode(coding)
                if len(uni) == 1:
                    code = ord(uni)
                elif len(uni)==3 and uni[0]=='%':
                    i = 0
                    try:
                        i = int(uni[1:], 16)
                    except ValueError:
                        pass
                    else:
                        code = i

        if code:
            im = Image.open(path)
            unis.append((code, {
                'id': code,
                'path': path,
                'w': im.width,
                'h': im.height,
                'a': im.width
            }))
        else:
            print('忽略 %s' % f)

    import rectbin
    rects = [uni[1] for uni in unis]
    output_size = rectbin.calcPlacement(rects, False, spacing, max_size)
    if not output_size:
        raise RuntimeError('不能打包在(%d,%d)' % max_size)
    
    unis.sort(cmp=lambda u1,u2: u1[0]-u2[0])

    max_width = 0
    max_height = 0
    im_out = Image.new('RGBA', output_size, (0,0,0,0))

    for uni in unis:
        info = uni[1]

        info['y'] = output_size[1] - info['h'] - info['y']
        max_width = max(max_width, info['w'])
        max_height = max(max_height, info['h'])
        if info['path']:
            im = Image.open(info['path'])
            im_out.paste(im, (info['x'], info['y']))
        
    oname = os.path.join(output_dir, '%s%s' % (output_name, ext))
    im_out.save(oname)


    with open(os.path.join(output_dir, '%s.fnt' % output_name), 'w') as fnt:
        fnt.write('info face="" size=32 bold=0 italic=0 charset="" ' \
                  'unicode=1 stretchH=100 ' \
                  'smooth=1 aa=1 padding=0,0,0,0 spacing=1,1 outline=0\n' \
                  )

        fnt.write('common lineHeight=%d base=0 scaleW=%d scaleH=%d ' \
                  'pages=1 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0\n' \
                  % (max_height, output_size[0], output_size[1])
                )

        fnt.write('page id=%d file="%s%s"\n' % (0, output_name, ext) )
        fnt.write('chars count=%d\n' % (len(unis),))
        for uni in unis:
            u = uni[1]
            fnt.write('char id=%d x=%d y=%d width=%d height=%d '\
                      'xoffset=0 yoffset=0 xadvance=%d page=0 chnl=15 letter="%s"\n' \
                      % (u['id'], u['x'], u['y'], u['w'], u['h'], \
                         u.get('a', max_width), \
                         unichr(u['id']).encode(coding) ) \
                    )

        fnt.flush()
        fnt.close()

    print('done in (%d,%d)' % output_size)
    print('%d chars in %s' % (len(unis), input_dir) )


default_ext = '.png'
default_spacing = (1, 1)
default_max_size = (2048, 2048)
default_coding = 'gbk'

files = [
    {"input_dir" : 'E:/projects/lord_road/xian_shang/texture_packer/battle_tip',
     "output_dir" : 'E:/projects/lord_road/xian_shang/texture_packer',
     "output_name" : 'battle_tip',
    },
]

for file in files:
    generate( file["input_dir"], file["output_dir"], file["output_name"], \
              file.get('ext', default_ext), \
              file.get('spacing', default_spacing), \
              file.get('max_size', default_max_size), \
              file.get('coding', default_coding) )

print("OK...")
raw_input()
        
