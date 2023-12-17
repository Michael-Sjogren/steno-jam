
map = [
    'w','w','w'
    'w','f','w'
    'w','w','w'
]



def calc_entropy(tile_x, tile_y,map_width,map_height):

    entropy = 0
    for i in range(9):
        if i in [0 , 2, 4 , 6, 8]: continue 
        x = (i % 3) -1  
        y = int(i / 3) -1

        dx = tile_x + x
        dy = tile_y + y
        if map_width-1 >= dx and dx >= 0 and dy <= map_height-1\
            and dy >= 0:
            print(dx,dy)
            entropy += 1
        
    return entropy


