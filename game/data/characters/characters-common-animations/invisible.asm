anim_invisible:
; Frame 1
ANIM_FRAME_BEGIN(250)
ANIM_HURTBOX($00, $01, $00, $01)
ANIM_FRAME_END
; End of animation
ANIM_ANIMATION_END

#if (* - anim_invisible) <> ANIM_INVISIBLE_SIZE
#error wrong anim_invisible size constant
#endif

#print anim_invisible
