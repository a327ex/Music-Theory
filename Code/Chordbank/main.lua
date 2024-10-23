require 'anchor'

function init()
  an:anchor_start('Chordbank', 940, 940, 1, 1, 'tidal_waver')
  an:input_bind_all()
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
  key = 'C'

  an:add(object('harmonic_field'))
  an.harmonic_field:add(key_field('key_field_1', 20, 80))
  an.harmonic_field:add(key_buttons(20, 44, an.harmonic_field.key_field_1))
  an.harmonic_field:add(key_field('key_field_2', 20, 382))
  an.harmonic_field:add(key_buttons(20, 346, an.harmonic_field.key_field_2))
  an.harmonic_field:add(key_field('key_field_3', 20, 684))
  an.harmonic_field:add(key_buttons(20, 648, an.harmonic_field.key_field_3))
  -- an:add(key_buttons())
end

--[[
  Creates 15 buttons, one of for each key, that when clicked will change the chords shown in the attached key_field object.
--]]
function key_buttons(x, y, key_field)
  local keys = {'C', 'C#', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B', 'Cb'}
  return object():build(function(self)
    self.key_field = key_field
    for i = 1, 15 do
      self:add(an:ui_button_lt(x + (i-1)*32, y, 24, 24, function(button) -- this is named button so that it isn't confused with higher scope self (which is the key_buttons object)
        key = button.key
        key_field:set_key(key)
      end):build(function(button)
        button.key = keys[i]
      end):action(function(button, dt)
        game:rectangle(button.x, button.y, button.w, button.h, 0, 0, an.colors.white[0], 1)
        game:draw_text(button.key, 'JPN16', button.x, button.y)
      end))
    end
  end)
end

--[[
  Creates a key field that shows all chords for a given key in all modes. This is an 8 by 10 grid.
  Call "set_key" to change the chords shown to the given key.
--]]
function key_field(name, x, y)
  return object(name):build(function(self)
    self.key_grid = self:ui_grid_lt(x, y, an.w - 40, 10*24, 8, 10)
  end):action(function(self, dt)
    for _, _, c in self.key_grid:grid_pairs() do
      game:rectangle(c.x, c.y, c.w, c.h, 0, 0, an.colors.white[0], 1)
      game:draw_text(c and c.content or '', 'JPN16', c.x, c.y)
    end
  end):method('set_key', function(self, key)
    local index_to_static_content = {
      [{1, 2}] = 'Ionian',
      [{1, 3}] = 'Dorian',
      [{1, 4}] = 'Phrygian',
      [{1, 5}] = 'Lydian',
      [{1, 6}] = 'Mixolydian',
      [{1, 7}] = 'Aeolian',
      [{1, 8}] = 'Locrian',
      [{1, 9}] = 'Harmonic',
      [{1, 10}] = 'Functional',
      [{2, 1}] = '1',
      [{3, 1}] = '2',
      [{4, 1}] = '3',
      [{5, 1}] = '4',
      [{6, 1}] = '5',
      [{7, 1}] = '6',
      [{8, 1}] = '7',
    }
    local index_to_mode = {'', 'Ionian', 'Dorian', 'Phrygian', 'Lydian', 'Mixolydian', 'Aeolian', 'Locrian', 'Harmonic', 'Functional'}
    --{{{ key_to_chords
    local key_to_chords = {
      ['C'] = { -- C, D, E, F, G, A, B
        Ionian_3 =     {'C',     'Dm',    'Em',     'F',      'G',     'Am',    'Bdim'},
        Ionian_4 =     {'CM7',   'Dm7',   'Em7',    'FM7',    'G7',    'Am7',   'Bm7b5'},
        Dorian_3 =     {'Cm',    'Dm',    'Eb',     'F',      'Gm',    'Adim',  'Bb'},
        Dorian_4 =     {'Cm7',   'Dm7',   'EbM7',   'F7',     'Gm7',   'Am7b5', 'BbM7'},
        Phrygian_3 =   {'Cm',    'Db',    'Eb',     'Fm',     'Gdim',  'Ab',    'Bbm'},
        Phrygian_4 =   {'Cm7',   'DbM7',  'Eb7',    'Fm7',    'Gm7b5', 'AbM7',  'Bbm7'},
        Lydian_3 =     {'C',     'D',     'Em',     'F#dim',  'G',     'Am',    'Bm'},
        Lydian_4 =     {'CM7',   'D7',    'Em7',    'F#m7b5', 'GM7',   'Am7',   'Bm7'},
        Mixolydian_3 = {'C',     'Dm',    'Edim',   'F',      'Gm',    'Am',    'Bb'},
        Mixolydian_4 = {'C7',    'Dm7',   'Em7b5',  'FM7',    'Gm7',   'Am7',   'BbM7'},
        Aeolian_3 =    {'Cm',    'Ddim',  'Eb',     'Fm',     'Gm',    'Ab',    'Bb'},
        Aeolian_4 =    {'Cm7',   'Dm7b5', 'EbM7',   'Fm7',    'Gm7',   'AbM7',  'Bb7'},
        Locrian_3 =    {'Cdim',  'Db',    'Ebm',    'Fm',     'Gb',    'Ab',    'Bbm'},
        Locrian_4 =    {'Cm7b5', 'DbM7',  'Ebm7',   'Fm7',    'GbM7',  'Ab7',   'Bbm7'},
        Harmonic_3 =   {'Cm',    'Ddim',  'Eb+',    'Fm',     'G',     'Ab',    'Bdim'},
        Harmonic_4 =   {'CmM7',  'Dm7b5', 'EbM7+5', 'Fm7',    'G7',    'AbM7',  'Bdim'},
        Functional_3 = {'Cm',    'Ddim',  'Eb',     'Fm',     'G',     'Ab',    'Bdim'},
        Functional_4 = {'Cm7',   'Dm7b5', 'EbM7',   'Fm7',    'G7',    'AbM7',  'Bdim'},
      },
      ['C#'] = { -- C#, D#, E#, F#, G#, A#, B#
        Ionian_3 =     {'C#',     'D#m',    'E#m',    'F#',     'G#',     'A#m',    'B#dim'},
        Ionian_4 =     {'C#M7',   'D#m7',   'E#m7',   'F#M7',   'G#7',    'A#m7',   'B#m7b5'},
        Dorian_3 =     {'C#m',    'D#m',    'E',      'F#',     'G#m',    'A#dim',  'B'},
        Dorian_4 =     {'C#m7',   'D#m7',   'EM7',    'F#7',    'G#m7',   'A#m7b5', 'BM7'},
        Phrygian_3 =   {'C#m',    'D',      'E',      'F#m',    'G#dim',  'A',      'Bm'},
        Phrygian_4 =   {'C#m7',   'DM7',    'E7',     'F#m7',   'G#m7b5', 'AM7' ,   'Bm7'},
        Lydian_3 =     {'C#',     'D#',     'E#m',    'Fxdim',  'G#',     'A#m',    'B#m'},
        Lydian_4 =     {'C#M7',   'D#7',    'E#m7',   'Fxm7b5', 'G#M7',   'A#m7',   'B#m7'},
        Mixolydian_3 = {'C#',     'D#m',    'E#dim',  'F#',     'G#m',    'A#m',    'B'},
        Mixolydian_4 = {'C#7',    'D#m7',   'E#m7b5', 'F#M7',   'G#m7',   'A#m7',   'BM7'},
        Aeolian_3 =    {'C#m',    'D#dim',  'E',      'F#m',    'G#m',    'A',      'B'},
        Aeolian_4 =    {'C#m7',   'D#m7b5', 'EM7',    'F#m7',   'G#m7',   'AM7',    'B7'},
        Locrian_3 =    {'C#dim',  'D',      'Em',     'F#m',    'G',      'A',      'Bm'},
        Locrian_4 =    {'C#m7b5', 'DM7',    'Em7',    'F#m7',   'GM7',    'A7',     'Bm7'},
        Harmonic_3 =   {'C#m',    'D#dim',  'E+',     'F#m',    'G#',     'A',      'B#dim'},
        Harmonic_4 =   {'C#mM7',  'D#m7b5', 'EM7+5',  'F#m7',   'G#7',    'AM7',    'B#dim'},
        Functional_3 = {'C#m',    'D#dim',  'E',      'F#m',    'G#',     'A',      'B#dim'},
        Functional_4 = {'C#m7',   'D#m7b5', 'EM7',    'F#m7',   'G#7',    'AM7',    'B#dim'},
      },
      ['Db'] = { -- Db, Eb, F, Gb, Ab, Bb, C
        Ionian_3 =     {'Db',     'Ebm',    'Fm',    'Gb',    'Ab',     'Bbm',    'Cdim'},
        Ionian_4 =     {'DbM7',   'Ebm7',   'Fm7',   'GbM7',  'Ab7',    'Bbm7',   'Cm7b5'},
        Dorian_3 =     {'Dbm',    'Ebm',    'Fb',    'Gb',    'Abm',    'Bbdim',  'Cb'},
        Dorian_4 =     {'Dbm7',   'Ebm7',   'FbM7',  'Gb7',   'Abm7',   'Bbm7b5', 'CbM7'},
        Phrygian_3 =   {'Dbm',    'Ebb',    'Fb',    'Gbm',   'Abdim',  'Bbb',    'Cbm'},
        Phrygian_4 =   {'Dbm7',   'EbbM7',  'Fb7',   'Gbm7',  'Abm7b5', 'BbbM7' , 'Cbm7'},
        Lydian_3 =     {'Db',     'Eb',     'Fm',    'Gdim',  'Ab',     'Bbm',    'Cm'},
        Lydian_4 =     {'DbM7',   'Eb7',    'Fm7',   'Gm7b5', 'AbM7',   'Bbm7',   'Cm7'},
        Mixolydian_3 = {'Db',     'Ebm',    'Fdim',  'Gb',    'Abm',    'Bbm',    'Cb'},
        Mixolydian_4 = {'Db7',    'Ebm7',   'Fm7b5', 'GbM7',  'Abm7',   'Bbm7',   'CbM7'},
        Aeolian_3 =    {'Dbm',    'Ebdim',  'Fb',    'Gbm',   'Abm',    'Bbb',    'Cb'},
        Aeolian_4 =    {'Dbm7',   'Ebm7b5', 'FbM7',  'Gbm7',  'Abm7',   'BbbM7',  'Cb7'},
        Locrian_3 =    {'Dbdim',  'Ebb',    'Fbm',   'Gbm',   'Abb',    'Bbb',    'Cbm'},
        Locrian_4 =    {'Dbm7b5', 'EbbM7',  'Fbm7',  'Gbm7',  'AbbM7',  'Bbb7',   'Cbm7'},
        Harmonic_3 =   {'Dbm',    'Ebdim',  'Fb+',   'Gbm',   'Ab',     'Bbb',    'Cdim'},
        Harmonic_4 =   {'DbmM7',  'Ebm7b5', 'Fb7+5', 'Gbm7',  'Ab7',    'BbbM7',  'Cdim'},
        Functional_3 = {'Dbm',    'Ebdim',  'Fb',    'Gbm',   'Ab',     'Bbb',    'Cdim'},
        Functional_4 = {'Dbm7',   'Ebm7b5', 'FbM7',  'Gbm7',  'Ab7',    'BbbM7',  'Cdim'},
      },
      ['D'] = { -- D, E, F#, G, A, B, C#
        Ionian_3 =     {'D',     'Em',    'F#m',    'G',      'A',     'Bm',    'C#dim'},
        Ionian_4 =     {'DM7',   'Em7',   'F#m7',   'GM7',    'A7',    'Bm7',   'C#m7b5'},
        Dorian_3 =     {'Dm',    'Em',    'F',      'G',      'Am',    'Bdim',  'C'},
        Dorian_4 =     {'Dm7',   'Em7',   'FM7',    'G7',     'Am7',   'Bm7b5', 'CM7'},
        Phrygian_3 =   {'Dm',    'Eb',    'F',      'Gm',     'Adim',  'Bb',    'Cm'},
        Phrygian_4 =   {'Dm7',   'EbM7',  'F7',     'Gm7',    'Am7b5', 'BbM7',  'Cm7'},
        Lydian_3 =     {'D',     'E',     'F#m',    'G#dim',  'A',     'Bm',    'C#m'},
        Lydian_4 =     {'DM7',   'E7',    'F#m7',   'G#m7b5', 'AM7',   'Bm7',   'C#m7'},
        Mixolydian_3 = {'D',     'Em',    'F#dim',  'G',      'Am',    'Bm',    'C'},
        Mixolydian_4 = {'D7',    'Em7',   'F#m7b5', 'GM7',    'Am7',   'Bm7',   'CM7'},
        Aeolian_3 =    {'Dm',    'Edim',  'F',      'Gm',     'Am',    'Bb',    'C'},
        Aeolian_4 =    {'Dm7',   'Em7b5', 'FM7',    'Gm7',    'Am7',   'BbM7',  'C7'},
        Locrian_3 =    {'Ddim',  'Eb',    'Fm',     'Gm',     'Ab',    'Bb',    'Cm'},
        Locrian_4 =    {'Dm7b5', 'EbM7',  'Fm7',    'Gm7',    'AbM7',  'Bb7',   'Cm7'},
        Harmonic_3 =   {'Dm',    'Edim',  'F+',     'Gm',     'A',     'Bb',    'C#dim'},
        Harmonic_4 =   {'DmM7',  'Em7b5', 'FM7+5',  'Gm7',    'A7',    'BbM7',  'C#dim'},
        Functional_3 = {'Dm',    'Edim',  'F',      'Gm',     'A',     'Bb',    'C#dim'},
        Functional_4 = {'Dm7',   'Em7b5', 'FM7',    'Gm7',    'A7',    'BbM7',  'C#dim'},
      },
      ['Eb'] = { -- Eb, F, G, Ab, Bb, C, D
        Ionian_3 =     {'Eb',     'Fm',    'Gm',     'Ab',    'Bb',     'Cm',    'Ddim'},
        Ionian_4 =     {'EbM7',   'Fm7',   'Gm7',    'AbM7',  'Bb7',    'Cm7',   'Dm7b5'},
        Dorian_3 =     {'Ebm',    'Fm',    'Gb',     'Ab',    'Bbm',    'Cdim',  'Db'},
        Dorian_4 =     {'Ebm7',   'Fm7',   'GbM7',   'Ab7',   'Bbm7',   'Cm7b5', 'DbM7'},
        Phrygian_3 =   {'Ebm',    'Fb',    'Gb',     'Abm',   'Bbdim',  'Cb',    'Dbm'},
        Phrygian_4 =   {'Ebm7',   'FbM7',  'Gb7',    'Abm7',  'Bbm7b5', 'CbM7',  'Dbm7'},
        Lydian_3 =     {'Eb',     'F',     'Gm',     'Adim',  'Bb',     'Cm',    'Dm'},
        Lydian_4 =     {'EbM7',   'F7',    'Gm7',    'Am7b5', 'BbM7',   'Cm7',   'Dm7'},
        Mixolydian_3 = {'Eb',     'Fm',    'Gdim',   'Ab',    'Bbm',    'Cm',    'Db'},
        Mixolydian_4 = {'Eb7',    'Fm7',   'Gm7b5',  'AbM7',  'Bbm7',   'Cm7',   'DbM7'},
        Aeolian_3 =    {'Ebm',    'Fdim',  'Gb',     'Abm',   'Bbm',    'Cb',    'Db'},
        Aeolian_4 =    {'Ebm7',   'Fm7b5', 'GbM7',   'Abm7',  'Bbm7',   'CbM7',  'Db7'},
        Locrian_3 =    {'Ebdim',  'Fb',    'Gbm',    'Abm',   'Bbb',    'Cb',    'Dbm'},
        Locrian_4 =    {'Ebm7b5', 'FbM7',  'Gbm7',   'Abm7',  'BbbM7',  'Cb7',   'Dbm7'},
        Harmonic_3 =   {'Ebm',    'Fdim',  'Gb+',    'Abm',   'Bb',     'Cb',    'Ddim'},
        Harmonic_4 =   {'EbmM7',  'Fm7b5', 'GbM7+5', 'Abm7',  'Bb7',    'CbM7',  'Ddim'},
        Functional_3 = {'Ebm',    'Fdim',  'Gb',     'Abm',   'Bb',     'Cb',    'Ddim'},
        Functional_4 = {'Ebm7',   'Fm7b5', 'GbM7',   'Abm7',  'Bb7',    'CbM7',  'Ddim'},
      },
      ['E'] = { -- E, F#, G#, A, B, C#, D#
        Ionian_3 =     {'E',     'F#m',    'G#m',    'A',      'B',     'C#m',    'D#dim'},
        Ionian_4 =     {'EM7',   'F#m7',   'G#m7',   'AM7',    'B7',    'C#m7',   'D#m7b5'},
        Dorian_3 =     {'Em',    'F#m',    'G',      'A',      'Bm',    'C#dim',  'D'},
        Dorian_4 =     {'Em7',   'F#m7',   'GM7',    'A7',     'Bm7',   'C#m7b5', 'DM7'},
        Phrygian_3 =   {'Em',    'F',      'G',      'Am',     'Bdim',  'C',      'Dm'},
        Phrygian_4 =   {'Em7',   'FM7',    'G7',     'Am7',    'Bm7b5', 'CM7',    'Dm7'},
        Lydian_3 =     {'E',     'F#',     'G#m',    'A#dim',  'B',     'C#m',    'D#m'},
        Lydian_4 =     {'EM7',   'F#7',    'G#m7',   'A#m7b5', 'BM7',   'C#m7',   'D#m7'},
        Mixolydian_3 = {'E',     'F#m',    'G#dim',  'A',      'Bm',    'C#m',    'D'},
        Mixolydian_4 = {'E7',    'F#m7',   'G#m7b5', 'AM7',    'Bm7',   'C#m7',   'DM7'},
        Aeolian_3 =    {'Em',    'F#dim',  'G',      'Am',     'Bm',    'C',      'D'},
        Aeolian_4 =    {'Em7',   'F#m7b5', 'GM7',    'Am7',    'Bm7',   'CM7',    'D7'},
        Locrian_3 =    {'Edim',  'F',      'Gm',     'Am',     'Bb',    'C',      'Dm'},
        Locrian_4 =    {'Em7b5', 'FM7',    'Gm7',    'Am7',    'BbM7',  'C7',     'Dm7'},
        Harmonic_3 =   {'Em',    'F#dim',  'G+',     'Am',     'B',     'C',      'D#dim'},
        Harmonic_4 =   {'EmM7',  'F#m7b5', 'GM7+5',  'Am7',    'B7',    'CM7',    'D#dim'},
        Functional_3 = {'Em',    'F#dim',  'G',      'Am',     'B',     'C',      'D#dim'},
        Functional_4 = {'Em7',   'F#m7b5', 'GM7',    'Am7',    'B7',    'CM7',    'D#dim'},
      },
      ['F'] = { -- F, G, A, Bb, C, D, E
        Ionian_3 =     {'F',     'Gm',    'Am',     'Bb',    'C',     'Dm',    'Edim'},
        Ionian_4 =     {'FM7',   'Gm7',   'Am7',    'BbM7',  'C7',    'Dm7',   'Em7b5'},
        Dorian_3 =     {'Fm',    'Gm',    'Ab',     'Bb',    'Cm',    'Ddim',  'Eb'},
        Dorian_4 =     {'Fm7',   'Gm7',   'AbM7',   'Bb7',   'Cm7',   'Dm7b5', 'EbM7'},
        Phrygian_3 =   {'Fm',    'Gb',    'Ab',     'Bbm',   'Cdim',  'Db',    'Ebm'},
        Phrygian_4 =   {'Fm7',   'GbM7',  'Ab7',    'Bbm7',  'Cm7b5', 'DbM7',  'Ebm7'},
        Lydian_3 =     {'F',     'G',     'Am',     'Bdim',  'C',     'Dm',    'Em'},
        Lydian_4 =     {'FM7',   'G7',    'Am7',    'Bm7b5', 'CM7',   'Dm7',   'Em7'},
        Mixolydian_3 = {'F',     'Gm',    'Adim',   'Bb',    'Cm',    'Dm',    'Eb'},
        Mixolydian_4 = {'F7',    'Gm7',   'Am7b5',  'BbM7',  'Cm7',   'Dm7',   'EbM7'},
        Aeolian_3 =    {'Fm',    'Gdim',  'Ab',     'Bbm',   'Cm',    'Db',    'Eb'},
        Aeolian_4 =    {'Fm7',   'Gm7b5', 'AbM7',   'Bbm7',  'Cm7',   'DbM7',  'Eb7'},
        Locrian_3 =    {'Fdim',  'Gb',    'Abm',    'Bbm',   'Cb',    'Db',    'Ebm'},
        Locrian_4 =    {'Fm7b5', 'GbM7',  'Abm7',   'Bbm7',  'CbM7',  'Db7',   'Ebm7'},
        Harmonic_3 =   {'Fm',    'Gdim',  'Ab+',    'Bbm',   'C',     'Db',    'Edim'},
        Harmonic_4 =   {'FmM7',  'Gm7b5', 'AbM7+5', 'Bbm7',  'C7',    'DbM7',  'Edim'},
        Functional_3 = {'Fm',    'Gdim',  'Ab',     'Bbm',   'C',     'Db',    'Edim'},
        Functional_4 = {'Fm7',   'Gm7b5', 'AbM7',   'Bbm7',  'C7',    'DbM7',  'Edim'},
      },
      ['F#'] = { -- F#, G#, A#, B, C#, D#, E#
        Ionian_3 =     {'F#',     'G#m',    'A#m',    'B',      'C#',     'D#m',    'E#dim'},
        Ionian_4 =     {'F#M7',   'G#m7',   'A#m7',   'BM7',    'C#7',    'D#m7',   'E#m7b5'},
        Dorian_3 =     {'F#m',    'G#m',    'A',      'B',      'C#m',    'D#dim',  'E'},
        Dorian_4 =     {'F#m7',   'G#m7',   'AM7',    'B7',     'C#m7',   'D#m7b5', 'EM7'},
        Phrygian_3 =   {'F#m',    'G',      'A',      'Bm',     'C#dim',  'D',      'Em'},
        Phrygian_4 =   {'F#m7',   'GM7',    'A7',     'Bm7',    'C#m7b5', 'DM7',    'Em7'},
        Lydian_3 =     {'F#',     'G#',     'A#m',    'B#dim',  'C#',     'D#m',    'E#m'},
        Lydian_4 =     {'F#M7',   'G#7',    'A#m7',   'B#m7b5', 'C#M7',   'D#m7',   'E#m7'},
        Mixolydian_3 = {'F#',     'G#m',    'A#dim',  'B',      'C#m',    'D#m',    'E'},
        Mixolydian_4 = {'F#7',    'G#m7',   'A#m7b5', 'BM7',    'C#m7',   'D#m7',   'EM7'},
        Aeolian_3 =    {'F#m',    'G#dim',  'A',      'Bm',     'C#m',    'D',      'E'},
        Aeolian_4 =    {'F#m7',   'G#m7b5', 'AM7',    'Bm7',    'C#m7',   'DM7',    'E7'},
        Locrian_3 =    {'F#dim',  'G',      'Am',     'Bm',     'C',      'D',      'Em'},
        Locrian_4 =    {'F#m7b5', 'GM7',    'Am7',    'Bm7',    'CM7',    'D7',     'Em7'},
        Harmonic_3 =   {'F#m',    'G#dim',  'A+',     'Bm',     'C#',     'D',      'E#dim'},
        Harmonic_4 =   {'F#mM7',  'G#m7b5', 'AM7+5',  'Bm7',    'C#7',    'DM7',    'E#dim'},
        Functional_3 = {'F#m',    'G#dim',  'A',      'Bm',     'C#',     'D',      'E#dim'},
        Functional_4 = {'F#m7',   'G#m7b5', 'AM7',    'Bm7',    'C#7',    'DM7',    'E#dim'},
      },
      ['Gb'] = { -- Gb, Ab, Bb, Cb, Db, Eb, F
        Ionian_3 =     {'Gb',     'Abm',    'Bbm',     'Cb',    'Db',     'Ebm',    'Fdim'},
        Ionian_4 =     {'GbM7',   'Abm7',   'Bbm7',    'CbM7',  'Db7',    'Ebm7',   'Fm7b5'},
        Dorian_3 =     {'Gbm',    'Abm',    'Bbb',     'Cb',    'Dbm',    'Ebdim',  'Fb'},
        Dorian_4 =     {'Gbm7',   'Abm7',   'BbbM7',   'Cb7',   'Dbm7',   'Ebm7b5', 'FbM7'},
        Phrygian_3 =   {'Gbm',    'Abb',    'Bbb',     'Cbm',   'Dbdim',  'Ebb',    'Fbm'},
        Phrygian_4 =   {'Gbm7',   'AbbM7',  'Bbb7',    'Cbm7',  'Dbm7b5', 'EbbM7',  'Fbm7'},
        Lydian_3 =     {'Gb',     'Ab',     'Bbm',     'Cdim',  'Db',     'Ebm',    'Fm'},
        Lydian_4 =     {'GbM7',   'Ab7',    'Bbm7',    'Cm7b5', 'DbM7',   'Ebm7',   'Fm7'},
        Mixolydian_3 = {'Gb',     'Abm',    'Bbdim',   'Cb',    'Dbm',    'Ebm',    'Fb'},
        Mixolydian_4 = {'Gb7',    'Abm7',   'Bbm7b5',  'CbM7',  'Dbm7',   'Ebm7',   'FbM7'},
        Aeolian_3 =    {'Gbm',    'Abdim',  'Bbb',     'Cbm',   'Dbm',    'Ebb',    'Fb'},
        Aeolian_4 =    {'Gbm7',   'Abm7b5', 'BbbM7',   'Cbm7',  'Dbm7',   'EbbM7',  'Fb7'},
        Locrian_3 =    {'Gbdim',  'Abb',    'Bbbm',    'Cbm',   'Dbb',    'Ebb',    'Fbm'},
        Locrian_4 =    {'Gbm7b5', 'AbbM7',  'Bbbm7',   'Cbm7',  'DbbM7',  'Ebb7',   'Fbm7'},
        Harmonic_3 =   {'Gbm',    'Abdim',  'Bbb+',    'Cbm',   'Db',     'Ebb',    'Fdim'},
        Harmonic_4 =   {'GbmM7',  'Abm7b5', 'BbbM7+5', 'Cbm7',  'Db7',    'EbbM7',  'Fdim'},
        Functional_3 = {'Gbm',    'Abdim',  'Bbb',     'Cbm',   'Db',     'Ebb',    'Fdim'},
        Functional_4 = {'Gbm7',   'Abm7b5', 'BbbM7',   'Cbm7',  'Db7',    'EbbM7',  'Fdim'},
      },
      ['G'] = { -- G, A, B, C, D, E, F#
        Ionian_3 =     {'G',     'Am',    'Bm',     'C',      'D',     'Em',    'F#dim'},
        Ionian_4 =     {'GM7',   'Am7',   'Bm7',    'CM7',    'D7',    'Em7',   'F#m7b5'},
        Dorian_3 =     {'Gm',    'Am',    'Bb',     'C',      'Dm',    'Edim',  'F'},
        Dorian_4 =     {'Gm7',   'Am7',   'BbM7',   'C7',     'Dm7',   'Em7b5', 'FM7'},
        Phrygian_3 =   {'Gm',    'Ab',    'Bb',     'Cm',     'Ddim',  'Eb',    'Fm'},
        Phrygian_4 =   {'Gm7',   'AbM7',  'Bb7',    'Cm7',    'Dm7b5', 'EbM7',  'Fm7'},
        Lydian_3 =     {'G',     'A',     'Bm',     'C#dim',  'D',     'Em',    'F#m'},
        Lydian_4 =     {'GM7',   'A7',    'Bm7',    'C#m7b5', 'DM7',   'Em7',   'F#m7'},
        Mixolydian_3 = {'G',     'Am',    'Bdim',   'C',      'Dm',    'Em',    'F'},
        Mixolydian_4 = {'G7',    'Am7',   'Bm7b5',  'CM7',    'Dm7',   'Em7',   'FM7'},
        Aeolian_3 =    {'Gm',    'Adim',  'Bb',     'Cm',     'Dm',    'Eb',    'F'},
        Aeolian_4 =    {'Gm7',   'Am7b5', 'BbM7',   'Cm7',    'Dm7',   'EbM7',  'F7'},
        Locrian_3 =    {'Gdim',  'Ab',    'Bbm',    'Cm',     'Db',    'Eb',    'Fm'},
        Locrian_4 =    {'Gm7b5', 'AbM7',  'Bbm7',   'Cm7',    'DbM7',  'Eb7',   'Fm7'},
        Harmonic_3 =   {'Gm',    'Adim',  'Bb+',    'Cm',     'D',     'Eb',    'F#dim'},
        Harmonic_4 =   {'GmM7',  'Am7b5', 'BbM7+5', 'Cm7',    'D7',    'EbM7',  'F#dim'},
        Functional_3 = {'Gm',    'Adim',  'Bb',     'Cm',     'D',     'Eb',    'F#dim'},
        Functional_4 = {'Gm7',   'Am7b5', 'BbM7',   'Cm7',    'D7',    'EbM7',  'F#dim'},
      },
      ['Ab'] = { -- Ab, Bb, C, Db, Eb, F, G
        Ionian_3 =     {'Ab',     'Bbm',    'Cm',     'Db',    'Eb',     'Fm',    'Gdim'},
        Ionian_4 =     {'AbM7',   'Bbm7',   'Cm7',    'DbM7',  'Eb7',    'Fm7',   'Gm7b5'},
        Dorian_3 =     {'Abm',    'Bbm',    'Cb',     'Db',    'Ebm',    'Fdim',  'Gb'},
        Dorian_4 =     {'Abm7',   'Bbm7',   'CbM7',   'Db7',   'Ebm7',   'Fm7b5', 'GbM7'},
        Phrygian_3 =   {'Abm',    'Bbb',    'Cb',     'Dbm',   'Ebdim',  'Fb',    'Gbm'},
        Phrygian_4 =   {'Abm7',   'BbbM7',  'Cb7',    'Dbm7',  'Ebm7b5', 'FbM7',  'Gbm7'},
        Lydian_3 =     {'Ab',     'Bb',     'Cm',     'Ddim',  'Eb',     'Fm',    'Gm'},
        Lydian_4 =     {'AbM7',   'Bb7',    'Cm7',    'Dm7b5', 'EbM7',   'Fm7',   'Gm7'},
        Mixolydian_3 = {'Ab',     'Bbm',    'Cdim',   'Db',    'Ebm',    'Fm',    'Gb'},
        Mixolydian_4 = {'Ab7',    'Bbm7',   'Cm7b5',  'DbM7',  'Ebm7',   'Fm7',   'GbM7'},
        Aeolian_3 =    {'Abm',    'Bbdim',  'Cb',     'Dbm',   'Ebm',    'Fb',    'Gb'},
        Aeolian_4 =    {'Abm7',   'Bbm7b5', 'CbM7',   'Dbm7',  'Ebm7',   'FbM7',  'Gb7'},
        Locrian_3 =    {'Abdim',  'Bbb',    'Cbm',    'Dbm',   'Ebb',    'Fb',    'Gbm'},
        Locrian_4 =    {'Abm7b5', 'BbbM7',  'Cbm7',   'Dbm7',  'EbbM7',  'Fb7',   'Gbm7'},
        Harmonic_3 =   {'Abm',    'Bbdim',  'Cb+',    'Dbm',   'Eb',     'Fb',    'Gdim'},
        Harmonic_4 =   {'AbmM7',  'Bbm7b5', 'CbM7+5', 'Dbm7',  'Eb7',    'FbM7',  'Gdim'},
        Functional_3 = {'Abm',    'Bbdim',  'Cb',     'Dbm',   'Eb',     'Fb',    'Gdim'},
        Functional_4 = {'Abm7',   'Bbm7b5', 'CbM7',   'Dbm7',  'Eb7',    'FbM7',  'Gdim'},
      },
      ['A'] = { -- A, B, C#, D, E, F#, G#
        Ionian_3 =     {'A',     'Bm',    'C#m',    'D',      'E',     'F#m',    'G#dim'},
        Ionian_4 =     {'AM7',   'Bm7',   'C#m7',   'DM7',    'E7',    'F#m7',   'G#m7b5'},
        Dorian_3 =     {'Am',    'Bm',    'C',      'D',      'Em',    'F#dim',  'G'},
        Dorian_4 =     {'Am7',   'Bm7',   'CM7',    'D7',     'Em7',   'F#m7b5', 'GM7'},
        Phrygian_3 =   {'Am',    'Bb',    'C',      'Dm',     'Edim',  'F',      'Gm'},
        Phrygian_4 =   {'Am7',   'BbM7',  'C7',     'Dm7',    'Em7b5', 'FM7',    'Gm7'},
        Lydian_3 =     {'A',     'B',     'C#m',    'D#dim',  'E',     'F#m',    'G#m'},
        Lydian_4 =     {'AM7',   'B7',    'C#m7',   'D#m7b5', 'EM7',   'F#m7',   'G#m7'},
        Mixolydian_3 = {'A',     'Bm',    'C#dim',  'D',      'Em',    'F#m',    'G'},
        Mixolydian_4 = {'A7',    'Bm7',   'C#m7b5', 'DM7',    'Em7',   'F#m7',   'GM7'},
        Aeolian_3 =    {'Am',    'Bdim',  'C',      'Dm',     'Em',    'F',      'G'},
        Aeolian_4 =    {'Am7',   'Bm7b5', 'CM7',    'Dm7',    'Em7',   'FM7',    'G7'},
        Locrian_3 =    {'Adim',  'Bb',    'Cm',     'Dm',     'Eb',    'F',      'Gm'},
        Locrian_4 =    {'Am7b5', 'BbM7',  'Cm7',    'Dm7',    'EbM7',  'F7',     'Gm7'},
        Harmonic_3 =   {'Am',    'Bdim',  'C+',     'Dm',     'E',     'F',      'G#dim'},
        Harmonic_4 =   {'AmM7',  'Bm7b5', 'CM7+5',  'Dm7',    'E7',    'FM7',    'G#dim'},
        Functional_3 = {'Am',    'Bdim',  'C',      'Dm',     'E',     'F',      'G#dim'},
        Functional_4 = {'Am7',   'Bm7b5', 'CM7',    'Dm7',    'E7',    'FM7',    'G#dim'},
      },
      ['Bb'] = { -- Bb, C, D, Eb, F, G, A
        Ionian_3 =     {'Bb',     'Cm',    'Dm',     'Eb',    'F',     'Gm',    'Adim'},
        Ionian_4 =     {'BbM7',   'Cm7',   'Dm7',    'EbM7',  'F7',    'Gm7',   'Am7b5'},
        Dorian_3 =     {'Bbm',    'Cm',    'Db',     'Eb',    'Fm',    'Gdim',  'Ab'},
        Dorian_4 =     {'Bbm7',   'Cm7',   'DbM7',   'Eb7',   'Fm7',   'Gm7b5', 'AbM7'},
        Phrygian_3 =   {'Bbm',    'Cb',    'Db',     'Ebm',   'Fdim',  'Gb',    'Abm'},
        Phrygian_4 =   {'Bbm7',   'CbM7',  'Db7',    'Ebm7',  'Fm7b5', 'GbM7',  'Abm7'},
        Lydian_3 =     {'Bb',     'C',     'Dm',     'Edim',  'F',     'Gm',    'Am'},
        Lydian_4 =     {'BbM7',   'C7',    'Dm7',    'Em7b5', 'FM7',   'Gm7',   'Am7'},
        Mixolydian_3 = {'Bb',     'Cm',    'Ddim',   'Eb',    'Fm',    'Gm',    'Ab'},
        Mixolydian_4 = {'Bb7',    'Cm7',   'Dm7b5',  'EbM7',  'Fm7',   'Gm7',   'AbM7'},
        Aeolian_3 =    {'Bbm',    'Cdim',  'Db',     'Ebm',   'Fm',    'Gb',    'Ab'},
        Aeolian_4 =    {'Bbm7',   'Cm7b5', 'DbM7',   'Ebm7',  'Fm7',   'GbM7',  'Ab7'},
        Locrian_3 =    {'Bbdim',  'Cb',    'Dbm',    'Ebm',   'Fb',    'Gb',    'Abm'},
        Locrian_4 =    {'Bbm7b5', 'CbM7',  'Dbm7',   'Ebm7',  'FbM7',  'Gb7',   'Abm7'},
        Harmonic_3 =   {'Bbm',    'Cdim',  'Db+',    'Ebm',   'F',     'Gb',    'Adim'},
        Harmonic_4 =   {'BbmM7',  'Cm7b5', 'DbM7+5', 'Ebm7',  'F7',    'GbM7',  'Adim'},
        Functional_3 = {'Bbm',    'Cdim',  'Db',     'Ebm',   'F',     'Gb',    'Adim'},
        Functional_4 = {'Bbm7',   'Cm7b5', 'DbM7',   'Ebm7',  'F7',    'GbM7',  'Adim'},
      },
      ['B'] = { -- B, C#, D#, E, F#, G#, A#
        Ionian_3 =     {'B',     'C#m',    'D#m',    'E',      'F#',     'G#m',    'A#dim'},
        Ionian_4 =     {'BM7',   'C#m7',   'D#m7',   'EM7',    'F#7',    'G#m7',   'A#m7b5'},
        Dorian_4 =     {'Bm',    'C#m',    'D',      'E',      'F#m',    'G#dim',  'A'},
        Dorian_4 =     {'Bm7',   'C#m7',   'DM7',    'E7',     'F#m7',   'G#m7b5', 'AM7'},
        Phrygian_3 =   {'Bm',    'C',      'D',      'Em',     'F#dim',  'G',      'Am'},
        Phrygian_4 =   {'Bm7',   'CM7',    'D7',     'Em7',    'F#m7b5', 'GM7',    'Am7'},
        Lydian_3 =     {'B',     'C#',     'D#m',    'E#dim',  'F#',     'G#m',    'A#m'},
        Lydian_4 =     {'BM7',   'C#7',    'D#m7',   'E#m7b5', 'F#M7',   'G#m7',   'A#m7'},
        Mixolydian_3 = {'B',     'C#m',    'D#dim',  'E',      'F#m',    'G#m',    'A'},
        Mixolydian_4 = {'B7',    'C#m7',   'D#m7b5', 'EM7',    'F#m7',   'G#m7',   'AM7'},
        Aeolian_3 =    {'Bm',    'C#dim',  'D',      'Em',     'F#m',    'G',      'A'},
        Aeolian_4 =    {'Bm7',   'C#m7b5', 'DM7',    'Em7',    'F#m7',   'GM7',    'A7'},
        Locrian_3 =    {'Bdim',  'C',      'Dm',     'Em',     'F',      'G',      'Am'},
        Locrian_4 =    {'Bm7b5', 'CM7',    'Dm7',    'Em7',    'FM7',    'G7',     'Am7'},
        Harmonic_3 =   {'Bm',    'C#dim',  'D+',     'Em',     'F#',     'G',      'A#dim'},
        Harmonic_4 =   {'BmM7',  'C#m7b5', 'DM7+5',  'Em7',    'F#7',    'GM7',    'A#dim'},
        Functional_3 = {'Bm',    'C#dim',  'D',      'Em',     'F#',     'G',      'A#dim'},
        Functional_4 = {'Bm7',   'C#m7b5', 'DM7',    'Em7',    'F#7',    'GM7',    'A#dim'},
      },
      ['Cb'] = { -- Cb, Db, Eb, Fb, Gb, Ab, Bb 
        Ionian_3 =     {'Cb',     'Dbm',    'Ebm',     'Fb',    'Gb',     'Abm',    'Bbdim'},
        Ionian_4 =     {'CbM7',   'Dbm7',   'Ebm7',    'FbM7',  'Gb7',    'Abm7',   'Bbm7b5'},
        Dorian_3 =     {'Cbm',    'Dbm',    'Ebb',     'Fb',    'Gbm',    'Abdim',  'Bbb'},
        Dorian_4 =     {'Cbm7',   'Dbm7',   'EbbM7',   'Fb7',   'Gbm7',   'Abm7b5', 'BbbM7'},
        Phrygian_3 =   {'Cbm',    'Dbb',    'Ebb',     'Fbm',   'Gbdim',  'Abb',    'Bbbm'},
        Phrygian_4 =   {'Cbm7',   'DbbM7',  'Ebb7',    'Fbm7',  'Gbm7b5', 'AbbM7',  'Bbbm7'},
        Lydian_3 =     {'Cb',     'Db',     'Ebm',     'Fdim',  'Gb',     'Abm',    'Bbm'},
        Lydian_4 =     {'CbM7',   'Db7',    'Ebm7',    'Fm7b5', 'GbM7',   'Abm7',   'Bbm7'},
        Mixolydian_3 = {'Cb',     'Dbm',    'Ebdim',   'Fb',    'Gbm',    'Abm',    'Bbb'},
        Mixolydian_4 = {'Cb7',    'Dbm7',   'Ebm7b5',  'FbM7',  'Gbm7',   'Abm7',   'BbbM7'},
        Aeolian_3 =    {'Cbm',    'Dbdim',  'Ebb',     'Fbm',   'Gbm',    'Abb',    'Bbb'},
        Aeolian_4 =    {'Cbm7',   'Dbm7b5', 'EbbM7',   'Fbm7',  'Gbm7',   'AbbM7',  'Bbb7'},
        Locrian_3 =    {'Cbdim',  'Dbb',    'Ebbm',    'Fbm',   'Gbb',    'Abb',    'Bbbm'},
        Locrian_4 =    {'Cbm7b5', 'DbbM7',  'Ebbm7',   'Fbm7',  'GbbM7',  'Abb7',   'Bbbm7'},
        Harmonic_3 =   {'Cbm',    'Dbdim',  'Ebb+',    'Fbm',   'Gb',     'Abb',    'Bbdim'},
        Harmonic_4 =   {'CbmM7',  'Dbm7b5', 'EbbM7+5', 'Fbm7',  'Gb7',    'AbbM7',  'Bbdim'},
        Functional_3 = {'Cbm',    'Dbdim',  'Ebb',     'Fbm',   'Gb',     'Abb',    'Bbdim'},
        Functional_4 = {'Cbm7',   'Dbm7b5', 'EbbM7',   'Fbm7',  'Gb7',    'AbbM7',  'Bbdim'},
      },
    }
    --}}}

    local chord_to_key_and_modes = {
      ['C'] = {
        'C/Ionian', 'C/Lydian', 'C/Mixolydian',
        'D/Dorian', 'D/Mixolydian', 'D/Aeolian',
        'E/Phrygian', 'E/Aeolian', 'E/Locrian', 'E/Harmonic', 'E/Functional',
        'F/Ionian', 'F/Lydian', 'F/Harmonic', 'F/Functional',
        'F#/Locrian', 'Gb/Locrian',
        'G/Ionian', 'G/Dorian', 'G/Mixolydian',
        'A/Dorian', 'A/Phrygian', 'A/Aeolian', 'A/Functional',
        'Bb/Lydian',
        'B/Phrygian', 'B/Locrian', 'Cb/Phrygian', 'Cb/Locrian',
      },
      ['Cm'] = {
        'C/Dorian', 'C/Phrygian', 'C/Aeolian', 'C/Harmonic', 'C/Functional',
        'C#/Lydian', 'Db/Lydian',
        'D/Phrygian', 'D/Locrian',
        'Eb/Ionian', 'Eb/Lydian', 'Eb/Mixolydian',
        'F/Dorian', 'F/Mixolydian', 'F/Aeolian',
        'G/Phrygian', 'G/Aeolian', 'G/Locrian', 'G/Harmonic', 'G/Functional',
        'Ab/Ionian', 'Ab/Lydian',
        'A/Locrian', 
        'Bb/Ionian', 'Bb/Dorian', 'Bb/Mixolydian',
      },
      ['C#'] = {
        'C#/Ionian', 'C#/Lydian', 'C#/Mixolydian',
        'Db/Ionian', 'Db/Lydian', 'Db/Mixolydian',
        'Eb/Dorian', 'Eb/Mixolydian', 'Eb/Aeolian',
        'F/Phrygian', 'F/Aeolian', 'F/Locrian', 'F/Harmonic', 'F/Functional',
        'F#/Ionian', 'F#/Lydian', 'F#/Harmonic', 'F#/Functional',
        'Gb/Ionian', 'Gb/Lydian', 'Gb/Harmonic', 'Gb/Functional',
        'G/Locrian',
        'Ab/Ionian', 'Ab/Dorian', 'Ab/Mixolydian', 
        'Bb/Dorian', 'Bb/Phrygian', 'Bb/Aeolian', 'Bb/Functional',
        'B/Lydian', 'Cb/Lydian',
      }
      ['C#m'] = {
        'C#/Dorian', 'C#/Phrygian', 'C#/Aeolian', 'C#/Harmonic', 'C#/Functional',
        'Db/Dorian', 'Db/Phrygian', 'Db/Aeolian', 'Db/Harmonic', 'Db/Functional',
        'D/Lydian',
        'Eb/Phrygian', 'Eb/Locrian',
        'E/Ionian', 'E/Lydian', 'E/Mixolydian',
        'F#/Dorian', 'F#/Mixolydian', 'F#/Aeolian',
        'Gb/Dorian', 'Gb/Mixolydian', 'Gb/Aeolian',
        'Ab/Phrygian', 'Ab/Aeolian', 'Ab/Locrian', 'Ab/Harmonic', 'Ab/Functional',
        'A/Ionian', 'A/Lydian',
        'Bb/Locrian',
        'B/Ionian', 'B/Dorian', 'B/Mixolydian', 'Cb/Ionian', 'Cb/Dorian', 'Cb/Mixolydian',
      }
    }

    local grid = self.key_grid
    for i, j, c in grid:grid_pairs() do
      for k, sc in pairs(index_to_static_content) do
        if k[1] == i and k[2] == j then
          c.content = sc
        end
      end
      if i == 1 and j == 1 then
        c.content = key
      elseif i > 1 and j > 1 then
        c.content = key_to_chords[key][index_to_mode[j] .. '_4'][i-1]
      end
    end
  end)
end
