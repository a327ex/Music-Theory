require 'anchor'

function init()
  an:anchor_start('Chordbank', 940, 940, 1, 1, 'tidal_waver')

  an:font('JPN16', 'assets/Mx437_DOS-V_re_JPN16.ttf', 16)

  an:shader('shadow', nil, [[
    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
      return vec4(0.15, 0.15, 0.15, Texel(texture, tc).a*0.5);
    }
  ]])

  back = object():layer()
  shadow = object():layer()
  game = object():layer()
  front = object():layer()
  ui = object():layer()

  function an:draw_layers()
    back:layer_draw_commands()
    game:layer_draw_commands()
    front:layer_draw_commands()
    ui:layer_draw_commands()

    shadow:layer_draw_to_canvas('main', function()
      game:layer_draw('main', 0, 0, 0, 1, 1, an.colors.white[0], 'shadow', true)
      front:layer_draw('main', 0, 0, 0, 1, 1, an.colors.white[0], 'shadow', true)
      ui:layer_draw('main', 0, 0, 0, 1, 1, an.colors.white[0], 'shadow', true)
    end)

    self:layer_draw_to_canvas('main', function()
      back:layer_draw()
      shadow.x, shadow.y = 1.5, 1.5
      shadow:layer_draw()
      game:layer_draw()
      front:layer_draw()
      ui:layer_draw()
    end)

    self:layer_draw('main', 0, 0, 0, self.sx, self.sy)
  end

  flash_color = an.colors.white[0]
  create_key_harmonic_field()
end

function create_key_harmonic_field(key)
  local set_grid_contents = function(grid)
    local index_to_content = {
      [{1, 2}] = 'Ionian',
      [{1, 3}] = 'Dorian',
      [{1, 4}] = 'Phrygian',
      [{1, 5}] = 'Lydian',
      [{1, 6}] = 'Mixolydian',
      [{1, 7}] = 'Aeolian',
      [{1, 8}] = 'Locrian',
      [{1, 9}] = 'Harmonic',
      [{1, 10}] = 'Functional',
      [{2, 1}] = '1'
      [{3, 1}] = '2'
      [{4, 1}] = '3'
      [{5, 1}] = '4'
      [{6, 1}] = '5'
      [{7, 1}] = '6'
      [{8, 1}] = '7'
    }
    local key_to_chords = {
      ['C'] = {
        Ionian_3 = {'C',   'Dm',  'Em',  'F',   'G',  'Am',  'Bdim'},
        Ionian_4 = {'CM7', 'Dm7', 'Em7', 'FM7', 'G7', 'Am7', 'Bm7b5'},
        Dorian_3 = {'Cm',  'Dm',  'Eb',   'F',  'Gm',  'Adim',  'Bb'},
        Dorian_4 = {'Cm7', 'Dm7', 'EbM7', 'F7', 'Gm7', 'Am7b5', 'BbM7'},
        Phrygian_3 = {'Cm',  'Db',   'Eb',  'Fm',  'Gdim',  'Ab',   'Bbm'},
        Phrygian_4 = {'Cm7', 'DbM7', 'Eb7', 'Fm7', 'Gm7b5', 'AbM7', 'Bbm7'},
        Lydian_3 = {'C',   'D',  'Em',  'F#dim',  'G',   'Am',  'Bm'},
        Lydian_4 = {'CM7', 'D7', 'Em7', 'F#m7b5', 'GM7', 'Am7', 'Bm7'},
        Mixolydian_3 = {'C',  'Dm',  'Edim',  'F',   'Gm',  'Am',  'Bb'},
        Mixolydian_4 = {'C7', 'Dm7', 'Em7b5', 'FM7', 'Gm7', 'Am7', 'BbM7'},
        Aeolian_3 = {'Cm', 'Ddim', 'Eb', 'Fm', 'Gm', 'Ab', 'Bb'},
        Locrian_3 = {'Cdim', 'Db', 'Ebm', 'Fm', 'Gb', 'Ab', 'Bbm'},
        Harmonic_3 = {'Cm', 'Ddim', 'Eb+', 'Fm', 'G', 'Ab', 'Bdim'},
        Functional_3 = {'Cm', 'Ddim', 'Eb', 'Fm', 'G', 'Ab', 'Bdim'},
      }

    }
    for i, j, c in grid:grid_pairs() do
    end
  end

  an:add(object():build(function(self)
    self.main_key_grid = self:ui_grid_lt(20, 80, an.w - 40, 10*24, 8, 10)
  end):action(function(self, dt)
    for _, _, c in self.main_key_grid:grid_pairs() do
      game:rectangle(c.x, c.y, c.w, c.h, 0, 0, an.colors.white[0], 1)
    end

    local ionian = self.main_key_grid:grid_get(1, 2)
    game:draw_text('Ionian', 'JPN16', ionian.x, ionian.y)
  end))
end
