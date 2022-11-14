# TODO
# select=$(man -k -l '' \
#     | cut -d ' ' -f1,2 \
#     | sort \
#     | fzf -m -e -i --preview "man {1}{2}" \
#         --preview-window "right:70%" \
#     | tr -d ' ' \
# )