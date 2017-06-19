ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# Start all composer
docker-compose -p composer -f docker-compose-playground-unstable.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.hfc-key-store
tar -cv * | docker exec -i composer tar x -C /home/composer/.hfc-key-store

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start"

# removing instalation image
rm "${DIR}"/install-hlfv1-unstable.sh

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��GY �=M��Hv��dw���A'@�9������}v;=��>,Q��i8=U�(Q���D�/rrH�=$���\����r�1��{�)�\r
�RERj}��Ö{�|�-��U����z��Xn�rAY��u��4n�@k�iIu��=����B�E�'�R���H�~@�i����8C?��������� =��ː���oS���0]����aBc����# �1a����fI��3M���i�S���*k���Pa�rR?3��&C�i���t� '����y�Am��փ�5A�b�X*g|��ʦ���^x=�� ЀMi�Z��iP��Õ���0�m�)�E|3�B^D5�l�`��b��YۻǓ)J����KA�������B�^�Cz��Ǉ�Z�t��"�zN%O��M9�P����ܹ҃��B-��T�h�с�_.�-�|���P1/-�/�K��^9��^��R���,��Z�InKHSN�����V��g��h�h�ZZƐ%��	�m��#Vei��H��K��W�,uڇ����д*��ឨ���_�hyL{�Cd*��'|-��j�̛���"�7���m��&
��AUH.+K�`8_�v`=[��7Z�nt�y׏��MR'^eޝ�y���v�[W9���G#�|�4�$�G���&�?��t��2@��s�>����-(��XUM:�a�l߉����Z��h/���t�0�x?��<���+Y��6A<[̀�@s�!`�%tU�� ��C�
!0��h�ˠ�$��P���xM%z�ѓ�3�@����/A����& ��� x�w�!o�9D�-!��t |�|H4`Im��ػ�>������3�ĥY��Z�����!k��!61�7X��� �Y�9Q�	$�u1����Ȭtɴ��-��y�mf�m{�
�z�i���n8�����}��M�@�X��q�{S�Ӏ�+�����(�5u�eF�:�}s���k��Ru���������ra�:�:��HP.Q���%J&&TQ* �"���D��[ ܯ��g����#l�A֓y <%���P4�6���߽zx��p�*L�3�]	<uL�9 uJ���/(O]�<_nఆ��H��rhJ2��5��D<>��"ל�:�{�a��h�q��p��0T��h<���ۀ�������z���P�a��#��j��/)���� ��+з�y�^)�n�+�2��5ps���з�m�o�6\���W����V���V���a��`���ij1��G���o�����le���~(x�XUA0�7`S�f��7��A���:w��/P��d����'����Pq?������+��R�o���GF_��i?���{$I8���Ǉ�ܝ��h���Q�y�V���hN&��!����a��׀��cⶑ@-���U�J�T���&�5��{�:og���3�oc�����x�:�r�,v(T��b����喙��5� 4Z� �4=L�=y��G���o���"�j��}��V��G�U�Y�S��o��Vjg��(j빞C[�;OL���0�.=�\�}:�>�2���?Iw_={��C~	^��V��9xd@���nG:KkY����:4�ۯ��Ζ�q[,��(�9O��(�sq�6���@(��Q�p&��A^w�q��?q*���l6���pw��O�������T���6���˦�&�G����L4B���6`����ga]Cs�aZ �n|����:�@T�'�h"D�8�W��/�[G���j{`9�{"�G��Sj=�ն@}��a��c!¡���s/��`s����/�8'l~L��u��.��?�,��p8���lީ����K��%���Uɂ�O��=�"&G>q�����Q�_��%bg�H�Q!*X�����,ݢ���͛y/�܂�>�ۍ���W�����M�M�?^��g+p�Ӵ�צp�96-��7�מ�W����q����1_�ə�ɪ.K8>@^�xh�@�h�����{��/��[��m����{��3�6zlYo@0w<!��^{v��c",��nY���c�f|�)\?�����M�?�-�&���[�w�����W;��fm���e�A�9mI��,F��Ah�M�pTo��3�݆��M&�S9~�<�9�W����*���Z�����z��a����"�xgs�U����$��#(#�� _�g%A���<���lr�*�*r_�/���>	-��M{f��ة8��~��*r �~E�)�0�	 ��uo����/�c�.q�fߦҲF�-d��<^芶�	��9�:�a��KQ��(*�b[
��Ph�T]�?��[������q���nn��Y��&��Xd��/T��.�?��#��� ~�	�8���/~��/�����w�M5��wt��F���0Bɻ�e�7Q&.��27�t��MI�G�2U�Qr��X4K$v �;24��?�{����M4s�/������E�/>y�ۏ���f�W�1qIt�����響,�li狝�?En�A>t���v~|�B^�L4y*������W�xY��?~���w9����~�(� ~�xas��?���b���Q�O�������>��lZ��*����
��z��;Ab*�����?�����~�~��/�?O����dt�O;��JK���g��B�7���i#���Ë��p<���6`��O���0k�=OW��:�@��q
N]�=�Ea9�v���B�_ŞX��<��.�
�}�[}���|�m>>^��� �JB���r\��*���b��]����v؅��'1LCj���:#I�h|��R4��f,֔eؤ�&-IL=���2�z��܍I�HJLL:3�82t����.�Ay�{��PW=8#�)㾥O��(�GIS.j.=)K��u�f��b�D8����MW n��W�׎�b%)TЈK���Q̟��B~���z�l�&�d�"T��T���V�UQ�e��}<D6����4Mw,[G�2C-�AS1��`�3��1��Џ��8�_��xRv:��1����{��������&MC&[��ԝq����n�V;[�`�8#t��U����Cu"�9�y+�H�¬L�L[u��
��"���97����k]�W�����3�'�`_s?�J_���������q'_?τB�T�j�M�$��M�Ji4/
���t��#۹��).r�l!��Yp!N=�a�����t�MR��+�./A�@��*�\�t������k����&M]Uu/z�в�O<��3{�̸�<&R�L?H��3�]憯��Hΰ�����HMH1f�ӎ3'�A*�5G,�K�N�z�L�ZsEsVjG�JND��_�n^�B2��VklMp�M�5�c��>�wc���|��$9���k"��fnt7����w��z��e?	opI�{<G3�M�9ͼұҳ�vJ��}��\��h��m�8��u��Vw�T���a~i�>��
���\�8���#a�%�N��|�ɀ:�#�rح�I�젒�ޭ�ζ'V�ӈ�A�J}�x"��� �8��7�kѸ��o$�����6���_v�+h�X�a
}���x��_�6o��p�
������]^�ZyE�#3뿎�>):�
T�ȿ#~�`�C׭��6��@���?����S�����[��X���[�{��c̲�g|��؎�w6���;��|���������3�������x���ۀ�����[��#޷<>4ؖ������ϗ%����
1pB:[ �P�eSY��	N)!f�|���l#�b�,Ƕ���a9�j/J��i�$�lG����Z��v�S,��I���bٴ	�|�<,�ӂ����B���K<'��Lʔ�N�r/�?�	G"Wv긑X8`R��p:&N���Щ_�"'���b�~��ը
�)KN��|�0��.qؑ�C,#�0eS��K���H��B�TBec�����)sD���U8�ؓ��Ċh�ce��<9�O{��zOm��;�:u��k'G�Q�^��B_f
C���3n�d�;�N�t����Q�w99��z�`p��Zb�k�I���ًų哬�=ɖ�d��
�A�ZOu��y�����}\�䎆����T&��D�0����9ŖI-��.��#���ç���7�1�����1���i�N���D��ɱH����ȉX�(�z���4[>H!�s"k;u�-p�]�E��s�I�@�t8�lgu��+̰pd��ӰSK�c���f��n�A�!�Q�[-�=��[�#�4���+l�U�sz�HN�iJk(��F-�Υ��v��䉢����>E��d�FTʥ>E_�-���.vG��ЬB���ε��t�����pF�PH.[����w�!��cK�_����o����P����~��a����3������o	������~�}���Lx������)��&Q�c����\�al�ee�F�;�=�������rR�"�us����#Ⴍ��t��w�zZ��4} 	�T�=p��Z��)\��{(�cԋ&1J��cA�	����08=n��ǜyZ�v�5�#:8�
$;ӖbM���X�em�s�᲎SfO�:�M�u��,cx�.��j$�g���<]#�lK@����2,�e��Gh��J:��{��|�UJ���J�n�2�A^�f�D���y��s옉4�^gDZ���n�1نMf�l��*��K��T�4��8�~����ι~�=���T�Ö�Vg	��2�����2> _r�*"�6Wc�x�A�n����񼒗�4>7��s��Y�y:�(&�ѹb�r�|���W�1E�,�>�
Y6ɥXE`�D��?a��y�[8/�Z���\M!/^p��|8k�*��=!�Y�I��d+w~�3X�MyX7�'v3&���"N?��C.Q��,܇�E{����m��ɒ���O���;�����#������6`���ᠥ��
������S�����������J���mT�����BEdn�j�Y9}��]7��f�bg�]��l'ۮ����3iV[ɶ�\���D<�7���KL*ԃ�D+�׿��{]�p}�]>��g� ��ʽr�\�߯��1,���/�q�����ݜ��}���H��^n�b0��>9�;�~���*�[�w//�%*��d;T<�,���^S�S�`�]lt��<J������c�X/�Rtq�mo{d��a_%d��-}��b���6�c��UC�g9�������!~���Qm����>�_�~j��U��EdH/����hx���W�b��x�F�֏v�{��>~V�;�V�c����n�<p������F�}�.9�ݘs���)Ɏ&�k�W*����Z��t���_�h�������?������?�����`���?��k�.�������~�����zG�r9�KI�Z��QI$b:�#|<��:>IB<O��=�	��z�)R�7���]Յq���`a+gE*�d=�S�����y?�a�g}s���|R���٤�j��/�׳����j�?�QWA�L��㙚W��`>V܌U7�<2���*۬�$=��}�$�����Oƾ���C�Dd)��R����G���<9��_#����9����	<������G�(����O�O�?�4����������������ē�'�m�����>�u����Q��o[��g�?�i�����B��YL�Ő)���fY�
dF�q���P<OPy.Dx�Ɯ �ͦiD����������O��k�g������f��C��/]	����!*�{�7Q����4͢w�׳�U�Vۉ4�l1sT�����t��8Y�&w^�Q%-,4�2��v~�O�a�w+1��w�U��-ՊC�u;�E��
��oU�,�&�|��T��47r�n]���S���uM�����M���w�.��$A����M�����-Ӆ��_{tB����-����M����S4��&��w���w���_��Z�� �e�������l������� ��w���}}������Ǐ��g��x����x)�m./�RFQ5[����/�����E�:([���">��y��(ݎ�7�|��j@���p�c߈�8�8&3��4�u�2���x6
�}(��8LԞ���w4�[�˰���7�������i���h��hT"dHG�r�ueH:������)X�+�&�M��D_����au�p=�Rʽ���3��4�Y��Ot9dE�_��'�+E�S�3�Uy�VsT`�Wk)酻�\�xm���s��n}6��!~�{՗�8}�3���� ��5Z�� �e������O��������o�.��g���?5�B�'�B�g��O4�������'�������3����7A����ш�G$�F9Ű1E1�	d1TF19��I��D��D�1��C �8�s��h��"���p����v�����F��翹�)zj�xU���6�p��\J[ I�����o�x��_���9�M"fO/V]���׽yuCc�a��$��X,c�tJۅq:���Ϲ|��[�&r���V*�r�"8��V�������	��o�F����,M��?��O���7����?����?�� ������#���]���f���`��	���p�C{4�����ītX����u���Z�e���Z���m���ڣ+���Q���G�S���4bR��y�I� 2��)�#Y���4���Z���9�����X��h�_9��FS�+���ѷv���k��]�s��Q��-ֳ���2�cyҡ4��8ȭ�x���m����jM�)���F]�vx%��f2�]��2��V.��?f��NƈS�5�ۘ�C���[����?�G��?���2]X����G'��~�������m����G�?�_��'���'���P��P���-��c����h�����`����v�������?���"��3��c�#�@<�o���������`�N�����~�H�e�	
}�ر���ҧ�
��%u��H�h�0��W�CY�������1q�Ǟp�H�.��E��sq�Ͳ��� S���&d[�^�Ӟf+�L�%�����Y9?���������(��+
R8I��J���c:�>�'�$BNl������p�C[�\���-��c������5:����[��������C�������{��1�	����Ǯ�:�����-�?���?�������p�LY�H�,�c��r*�X!f"���$ai�Ҝ���3��i� �<ɓ�H�L���������+�?l|��3G��K��t�v���k��]�&�t�iY=��%�Ü҄v�M��N�;��b:J�����s��z�x�(��}T����c��K.�C�L�4�n�ަ+fl�����I��+��x+]X�!��=Z^�!��e�����k�N�?��Fw�F�� �>����������@��-����2��?v��	�������? 6ޙ.��!_�?��	�����#�C���͑g�Ë��f�~΄z�`���/��8?|3���o����x{��5~��n���Q��ęG/��>���x���tG����Ak�1,�V>���RWr�_��F�ś�°�z�>��P�	'�����"�L���\�����,�sq�U�_>��:�xt�u���N�`U+u8ľ�H��c���0'�Y E>O�x�'�8]�y]�P�/tU��`��=/���GK�AԷn .뤿s,�ރ��=��[Q�}���a��j����di��������ϰ�=��Y��c��a�5�4>�sUd���o\4P��ה�{��P�ס���)�(��h��ݒ�L��~Od6������0��a�<�d��D+{�����T¾�*�V�j��X��;�08���o�e�����z@p�*��p��}\�4�s-sV���F�֩�߅k9��,)�h��/�zǹ��w��o����F�������]�uB�!��5:����[��������C������C�ɿD<�D�O�4��MЅ������?��o�����9V���Y���f���o�N�?�j���I��&hF��_W��o[�I�I��7B���G#����Д�����4����^7+�.�|^��&�2��|��߫�::�w��������E���D��X	r�����|^Sg/�c,�g�l*{�]RN��k�G�O%�������2�pō��v�������V�'�6����#El�*�n~(����=��I���5}�����:��ӌ����(�7�#ӻ}p�*j�߈�g�;!����+�7ɂl��Z;7uv�1�������iqFO�e,jv1�]���L�?���m�L����
���]�uA���w{4��`��E����?��5�?������)E5g�9�E,��Nd5�n����[��^=Ե������?��?y:��cF)���������˛wr�����&tnf�)�pr����ý����Ѯ9�3&lMw����&Y�M�����36�ey�&�{��j�p���ц�|p͏J�_���,*h)��n���V����=�������@9�Wg���vz.FEV�bU�2e}%���*E>Z�lEc[��պhL����K»P��T{��?���L����
���]�uA���w{4�����������������߮�����x����8������3��"��7A��ğ�����������=	 Z���u�'������FhY����������߶�Sē�?��G#tE�y"�<�
gh�#>�x!�p2"pJ�3<�,�9!~y�d#�%��ds��sN`�s|���7]��%^�?�6�7���5��KW¯�?u�
E�^�IT�:z�M�(׫�=��Ex�Ǖ��V�vs�pZ	Z1V���������B	!+�.(s6)�n�4}���d�WkÎ(g�K��}���`���N@�@�
.Z/����.��s2A�Q�
��;��M���w�.��$A����M����P-Ӆ��_{tB���k���?C�AS����O��	 �	� �	� ���?�j������?����o#tF��? �����g_��$��7�?������T������{��/M��Ђt<Tc�7=����!�_�(�D��I���;�}���`�)VÜ��վr�Mlv1�j���}�.��6��)aR�lJ\�+����I'=��u�Z25���0o[�K��z����`'#��O��ϷG;�o�v�!C:���O��ʐt��yL<�_]FX�D��Q�&���3İ&�r��^M�����^����;�^ Cq��)��� �<�g����t���Fcrѯ�z5w.�=bQ�֣����.\�������h��cf�;&�\�z�\�G�E�����|��� ��5Z�� �e������O��������o�.��g�O��	 �	� �	�Z�������Fx��?���w�&�������	�����o�F��f�a�<�\ȸ�86IsFH��Ii�d��g�J��ֺl��+j�Z�A�!I 	$Ĥ�z����b��	Tb���]�ك�$V����}ι��)CG8�GC��ELĤ!�i�&p��À�?��M��-�������*wN����`3b�{�#����%[]�����ʹS�r��b5��b���ۛbi�f8$I��*&oq؄��eL�񂇪r�L(|�)��z7_$U!{�Ӭ8;Q�;na�&p���@��'���?��kA-�?T��E]��{�����?������� ��c��c	��E�������XP���������>p,4������?4����?4������?4T��	���(L҄!.B>I��gF�#*����(�9<�8�	����K9���F�~(�����?j������]x�`ͯ:G��ź'c�t��Mz�B���X.�
Ǘ��1�d�i�<�
biǼՓW��kKw�W�֖�M��(���7)޴��`���r�:۔���eۻ�.b����(�����94|����������9 ������Z��Ðh����;��p��� ���'���'� �׀�������H�?�?4d��?6�����,����G���a�#� �׀�������H�?�h��?��������s��?������� ����or����� ��s�?$��?C������i�����
�G����Q@PlJpi��d,C�L��Bx�qB�t@�a�޶TJ@���������'�?��F�g�Jf���V�ڌ1۝��8�³|���|!V/�6y
<�w���4��In�a���W��ٱ�d�lMxJ8܊�%�	���K�_t��.3����a��N?���tx���V�p�C�Gsh�����������9 �������j0����`��`��?@�5�� ��a�����	����ƀ�?~ � �?Ͱ��_��e�����}П��!k���%���t!���?܈t���_�ĥ��e�h�f��z���N��i�:�'S��h6܌��N?�G�`H�Cy&x���Q'U��l-�s�#�1u)S?@6�ù�G���E�=o�����]���q��.ţ�K��0��r�+�u>cɖ�Ml�(�,�@O'��|2f�S}qn��iT��=p�6+��_c��$��4����4���[�!������������ ���C������%�o�q������x���9��_>���1��7�A��_>��_���o��M��_P��W���!�������?����͡f����B/2���:�E���h������vY�����g�YY0�/�1O�]~_������QD�k�W&���J͞����O�{�̗z=������/̰7�&~���|����r.�O=w`3�r!�s��31hsjg+����l��鮗�My4R�̕�kS�la�HO�p2bv���V�b����y����@$s?�����FǷ�v��*�3~�˸��2����q����^e�<{�݁��]�tX�/��p92Y2յbX�~o���e2�>Y��ɞ?g���D<Ւ{j�c�&������+�j�u�l>��J�ݛ�]�~y��ŅȎ�6��ۭ�E����.�cnj鞦�j﬷�ޒ7�g��z��U��������.y����[����$� ������`�Q�������������ǻo��';�i����Qw��s����ڟ���|h���ˬ�Đz_g��'ռ�8Ƥ,z�m�I��I���*��);�����o�<Y����&��ɓ������1ܧv<�zm;+��1��	���0w��&^1�j�����;�ڐE5���g�o�ϣZ7[��f}����^���z��(^_�ʗ$k�+�R�/όo�]�$N*�VY���/E�V{���;jY�R���G��Nxj?���9��)�;�/Ej-06���vLg����3��h�]�IT_�=~���q����m8ӥ��܆²���+�����a��wd��iG��0C}�lv�%me��P@A����{���jA�?\�B��?��C���������K^�e	e�f���Ǚ����������������y}��چ�?�ت�E����/���n[]�we�������m�q������h��[�\�W��s�������w�Nk�t�d�����h?�`�3G�EԶ-��nZ�Ԕ��uWu��|	b}�W姣�|5�<}0ǃx�j��l{N�U8��\�jӿf��ѿybY���HJ��vDki��t9�����0�rEg���A�R ���wϾ�ño�L4ԉ���iQa�'�f/�|Jz��6¤��6~Ժ�1��+c.�B��%�N�]wK��>!�Cm���5s+/�lϜ��t+����w�	��?��	��ԩ����P���i�������Ӭ�{�������)��?4������?
�_�U�/�o���O������*�*�ٴ��nE���xO�{-�0E<<E+{�^����y�~`�g�t%y�R�a��3r~<��vW>9��8O��C�bE��Zy�`7�T��g��䦝���Fǝ^\�w�W�ݠ8>�����o��n����d�:��Ï���/Ƽ�-y5���O[�h���1���^�c�dz��M�]f�t���!}ƷT�lgf����� \%f�m�C��}e *�����3��,��h5�	�D(���̀�����9�����`��d���2�W�U�Q#���[�?�B-��yK���Co�����hb����ӕW�X����U:vVe��sԃ�Qj#����霚�3I��*?��74��
��L�#����#�S^�O���e�6i����2����[����V{��{�"���쉊Թ������>b;�0w��)�VR@Ƌ��/قN�ʱ�����=9%N%����^4��PN²𫔡�x��p�+mv��$���"���0���Pl(�?��k<�����O���T��JԖ�`ѵ۱F�6`Rׇ�3\�YgQ�oڧR��0�eI���Pف[Uf������3.H�5�������:��hل=��u[�L�9���}W��������ģ�jw��I�OE�h�;呚m�A8]Lg���F��
�E�|���:�֎�cqJ��S��+Sʍ��=y�-��%���r�U�B��	��������~����� ���������P�� �_C�����@u������?�WN���:��s�?�_j����|���O ���8�����w��4��Er.�}Ac ��o���G�_��k�����A�D��@2,Ϧ��2l2�G�7]�@�� �A�|��1��[~������b�;�'a�������+���������3U�Y�I��*��-+���;;Z����>b�*�>#��-[���P�]��<�k�m�_1��a7]�w9k�OMSx�nf�h.FX����7�t�E�ؽpg�G�x���V���Vf�T���#Z��П�a�~���}RM�
�?I<��b��������q�p���kH�?}���5����͠.����+�s������?a�7�����/��~��!��4��`1x� �������m��?�_��o�@@�����_�����������������r�3�䍗�E�V(�=�?����������'�X_��)t�J����Q��/(v��"^���*e�N��V>��SVB��j֘��fi#+K����o�Gg82G���FO����im�<�mKz��9$y��̅����}�1�ncJ��"��ݪ����-�x��W�oM:Ru}�X��D�Q��{rI���F���{ˎ���x��Qʮ����V�7)-��˴(W;vf�9��:�w��|��;���J���}�%b�5��WN��,�idkRimG��4�>y 	����Q�����ϭ��������S��p��	����]������?~�����Q������!Y��u �Opw�P��	5����Gu�����w����� �������(�?�~����jA��	#�<����QJ1x"�)����+�aȲ)���G	�4'~�wB�@���.��������A�Ձ?��a������@k���îA��l⾻�*�v�������s���������x+P8��G�?�Ԃ���c	��(������������	���� ��&���w�p" ������������M�?D�����������i����	��$�lJR4�1���'�%�8L���D���d��@G	''Tݡ��Q�;���O��6��pIVs�nc��'��Bt������h��l�"x��8E�{�W�e��u��Y�r\טLR�Gs�����دXb��m}����PZ�b�ܞ̙���NY0l�3�?o
�?�������������h ���_s@�����0�W��� ������f`�������?��G���n�迚Д���w4 ��s�?$��z�����Z�<���&�������8�� ��`���{����������o��)���h ����H�?������Z�4���oH���7��C�������n�?T��>+��%�\��	�������O24��][�#�Y�f7��g�7C�����]f���]�7H��|/_����hT��]v�\U���� xY�����%��%o$B�H�#�R��)�����vO��>�i�����\��|�������X����o$���W���7��k�{�?��������������/�����ݺ��8�oe��2�a���;/�za������9�k�d;B�WtE��+�p�)��f@�"a�/���R$���p3�|�pDb���E�)�a>�n"{�;e�O����������w��������Ճ/~���q��9�8����P�0,G�k6�����ة�qR���m�;o�W�j��"��o���[�E��o����M���<)��˗� ��>����5� 6T[N�E-���օ38(�O�^[� �����+4���C4L��<�	�<��\zHw�X���L�˼1t	b���0S)O(����v+N�����jc h!��QU�(ͺ<��e,�i�1�WC���4'T�&�Y�6]�}�i6���K��%p>ѣ�K�yN	�~h��L��Z�ˉ�b�$Lk��Rl?Ǐi;Y�)ͮ��,>Ƃ�_댼N��Œ���CP��E[��l<k�L��s�~��0;xc
sl��:x�h1�w�Ћ�t��I,�xwv�VI!�q%�G���gUB�(����`R�����l(����=&V���B?���[�i�$�B�V4W�ױ&腺�^�<j���e9�;�L,H�Cv2F�������l���p��+ĥ�ݭ�P ����S��#r"Z�  �O^�D���+ULv&UCX��:#AԄbh<:c��0-$+�Н�4��a��A~��j8�a�u:��C5n�����=�je̹\En�EٌL
޸�+)F1�$� �q_�cjӉǚ��3�#;�E��@��+�@ˉ��a���}5�h�T��bT%�&���T:�B	\������q��8Ӷ
Q��Ҥ_b�L��-�^�I'��Q=(�4]�_�4���ħh��p�ni�4U���~rߛF�L'�^+a�3�m֔Z#�LD���G;�r0ْ�b�;���� 3Z����|�7�j�-�X�G�pٸH�z��B=!f�d��`�~y0N��z.���&���
^�T���y�"%AOQ��4y�>�
����%��l�ǋz8�-7̱�f�ĵ�T�b��l���Edi��*8���3̲F|���̒��8��Lx���)M�Uވ��h���'S�r���SfO�Z9�K����V��T"��VjT�U������H��8޺�Y<�\��َ�oM.𺔮�©AE���F����!_{��bB�sq\�\��:��%�����M���a��&�f�3Κ��6a��s���A�瘓�<�Lt�|�)�Iy8���lu4���(H�~��J0NYDV/�e(x�\$.OjzU�;�h�I<.��B���a��9�`� �cV27l��ڽ�_b�j�SÚ�� U��UP�,���.[04c�*��^���_O��T/kd-�̕�>]Tj��$�I5Ᏸ]9J�5&����O�!��R��y����Y�$6�$6+	�(���Ac���"���B�^bS8������^�Zcm��R�n��_F~a��mdy~~v�3{�!�.��e?�C� �	��RaymY��!�܄�xq�|����1-�\���o�}{w����|s��ݓ�˕wf����T�kK�p@���A�3��هXnByOo���!zޔwe���HJu�F� ݉u��<��v��hT��V�8�����y��g#E�.�6'�}eX�&&����`�T��� �q�,WS�j	3ٛPމ$W)��}I����U1��S�F���U8�����v>k�U�SPy�\{U��y�����[�V�;��ERC�Fٽ�ŵ�)���V�%u�V�U�*b�J�	/WL��E��Nc��p��	yM�[z��wZ���1R�.�j4�	*�@�%�8��3D�)Ďb���Pn��V��`�V�����D��h�J}@�ܓd�D��������,�����64�^-6QD�G��NO/���ӄX�믐��Wױ�h�:c�̸Z����YIҵ�P��fV���Xb(U�N1j�Ša�i~��82h�j�iѱ��&~"OSQ
T�RMʫ#�(����"�f(U�e�D1��)M"öROb��B,����{^�f��뺤�-i�+�"�����w^DvmY�����w/>u"����} �?]`����~pg��߻����[wN���%f�}�z��ާs�%߾�^"���(�K�sP��ZF����� w x1��]��e�a��/d���}���b�|k���Uo*>b&D�I#�d&%�ꔴ�?�k�r7f�QEN��CщJmR	D٫�M�������GhٛF۶4bh��dN|-8�L��nR�k��2�xd���b��K��z#�t��0��u땶!�I�(�P�+�>�]����3u�2�<_!�X(�����
u�d'�F�B���9��Vi����9�~�O��ck�z�K��Z�3f��z���ͽ�߸t	�F�n�^?�Q��4eN���#_�y�[�2����j�[���n^	[�@7���h����E��l�R�iD�� ���u��t�oscSBn!/��lC5�$�*�;B�U&�&�����G�����G��e^��p�&}�9��9,�Ӗ�R��d��Fvw^t��U���,i�+4��xy����[�]�| >O���VxU���G^o9T��-��mEo�jˀDmA\����; _�^��~^�u�����������/ɣ��|~pQ�$ۖl�=d�39\�9��B�'>�rv�gf�>��1�$�a�W���>�������<��#g���=����c�̇ab8�$Il6� /$>k���?�p�D9܌�0����`ԏdA�~�bf�����M�����$�Ӈ��k�~̍����<���.��\:�<)g,�3y�'9w��Y�+?�Y�wow����=�Q��I��������o$=3�������6=�8�[������kG��. �7= �����G���X�;��2Z�~4��؎����qՂ�3�����R!������VnxIBL&�Ut�,�P��i��J�6�!�#&��``�\^yi�gX]�rt:�ա�Q��^s��g n������_�\��������ܗ������V��������9�,g�sף٦"¼yh̱U�=Gz_U�zxYVTejf�D�T�a��I��J�?��\�����gEo�E�[qƐ�:�����ϴ�������q�(�Ȋ�;n/����<֯�p�_7l����5�^\3��X�n��~���c������u#���F��<�7�<��<�=>|���6=��1��"R|�-B�th�7��%�$���Cw��#�-��Hz�Kަ�{����]�)j訬X��J�eXwQ�W��WUj����!�%=��J�⛨ӖP�oYyQQ�$�1�1 ��=�{����U6��Φ2�>�}���z�6jE� KC,���B�t_8�KSw��9�k~�Bޖ���4>���%X�'�5�v�NϜD]�Ux�Fa��i�a�
��n-�uaC�����`�m��z�YW�?8K��{*5(�.�ѓn��n�����P�A��e�*$�_�p�NJ;��� ���M���)���,s���4���o�Ҷ,S8�zUC�նa;S�}8%���k�+��ws�N�s���.��S���˸�v���)�%��P�+39�#���ֲ�4�sA��gI�O+��}�A�@S��|1����P/~�ˠr�&ݒ�v=��٣$nI��� N1����zRp�,U[��k���6o�MI���&��aM�z�Vb�����r=\�tA�M��a�o����������|S���������ܜqц��L�� ��?�l��w#�����r����h�)�MW==��{O��5uytkܻJ�\�Ec��/^}�L�#�Ț�B�V�o$=U�rb��w�4X�*u\nn�}X�	u�ִ*��S�� I���-�p�>�tk�OH��N)�F���p��w5�E-�VW��r���_�6�G�-wԞ�����0����Hϫ������3��ə�����+:d��.�ێ���؇7�n��֍����b��1DU�uX�H�1P��j"��q,vk�f/�q���ܬfoj�%��μ�)C�I�s$83�W����ؔ�.�����к�G�������&iM8��@8�܎�C�:Hf�cM��ך35�܁9��=UA��e�/�hi_9@i�&(�e*��q�>�Sy��Q�=��C]L���rMD�5�7�K�Y��O�A�9�������;�5� ��~����8I2��e�@R��]%�а'd���s���2:�z���Z}}.G�6�X��+$��|�~��P�{$E��gn�&��9�]̦�Sp��n��̨;)�RsW�α�гT�̤���I|S��`o�E��Z�֨�O����ú��L�o69H�*zw9�Xmɀv=�;�*I&�ՙ	X7D�P�w���פ�uΛ���2���>�t���2 ]�����/���n$=����|��M�B�Ѿ����?x���ۻ~ߦ�(ܦ��� �2��@%�v'��@�V�R!Q�N ���Xuc+M�R	�1�ԁ����u�����T$�;;���I����-�|��?�=����}�$��c�|4�h��w�?�����������L"~bĻ�/[�D��4tE����jz���a��ί������`nfv~N^1���z�?�+�f�������[`R�E�m��&:4{x�4�z.qt��ҋ����Օ<��@|����Y��8q6E�%�V�v���a���Tlo��f�j.B6#B������RW~C>C���<ƴ<�}�}$�{�d*�vu�]��*�É�%�}������1l�'RG��?U��������޴�g @W�6n�i����bZ���!��.BPR��Ҡ7���5^��q:Z9Ti9���m�<��5j���Ղ��/��d4���+�*��v��VW��@c�XR�/ ����̈S��m��aӍ-�N�'B"أ�F=�
��ٸ" �53$��|�x<x:�d8^ŐC��ܱ�^wł/�?��#+X?g¥��XT5�JF�U�5~I饆�Y	�+���:����s����x;�'�\����­�Ҧ��rVVZ��%Sm%�c�x��~��vk'�#�'����U������y��2jFuG*��ɝ�.�&RG�ޠ��X�$&���f��ufe6e�3�a�LS�䍜�29��W����+�e��r
+X��\� ���K��v~��k����������G����g�N"�*��*�w��f<��e[��,���b2S�P
��1��k�pP6�~Xx1�zʍ���ԐN�IƮ�'��0I�x[�2,k&oK<6%��y����¯�o����~��^b{����������1\Og�l��>�r��Fw���c���id��?����H�M���@���.ep���L�Ϥ�L�Ϥ�L�:��C�Ϥ�L�Ϥ�L�Ϥ�L�Ϥ�L�Ϥ�L���8�9(���9h���]0�V���*�R����I����I����I����	�@ �@��f�� � 