ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
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
WORKDIR="$(pwd)/composer-data"
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
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.17.3
docker tag hyperledger/composer-playground:0.17.3 hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

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
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� c)kZ �<KlIv���Ճ$Nf�1�@��36?��I�h�&ْh��HQ�eǫivɖ�������^�%�I	0� � �9�l� 2��r�%A�yU�l6)ʒmY��,�f���{�^�_}�US9�vL1������˃�mz�t�wΧ$�d�i��	��/-)>��RBVH��P�g�\��<'��-���6B︶|�9'Ý��-��v4�ȣk�5�s�}�)��sB�N�yx&����3�.���Q��m��,l�Xmc;1l��L�uJ�b��br1�'�]���L�����%{�� q�Ŷ!��n����ܛ��7��䦭)1���6$Ν��\.s��C	�?�N����L��9wN�������?��B��N�h��Ϝ<�)��?ϧ2�B���\Z����(�'���h�N�sL�V0�.\G�JT�&���ĭ�����zQz�|�,�nD�ի�����MY�6��͗���@��ViL���X̲qK�n��Y��0�7-�oj�b�.�m�����hv��^����ؿ���T�D!��3����nE-�P\H
�ۑ]t��5ʆ�l�51Tbd{���QR�pA'�5��7����//\W�
!�A�'78�������?^F�(z|��4 ��J�D�u�Gp'p�N���g(
�0<]'�"�@�����ąq�r��p"�:��Y��]D�X��}F���K�f���À"��2�1�C2.��g��ǰF81���64���ؑ0s�0]�&��F�>b�Ց����7gXy���'4�4�HH�>�0|2�B�%��[�P�G�K������]5�q�v@P���J-G7u,;9XǊ�zM� Ӣ���r��Y�N�]ET�8�K��/�(!�����32m>�Gw ��&؊��\�0���I7�9�F�ic������ ������5��}���#+�jx>��2%���ܖ ���� L��9X ���E������f�E����9�8���t*E�x!�J�<��M��/��<���nZ]l�,;s[�\Ԃ�oJ�G�1��aI��-7Y���6A N��p/��X+o�m����������-��O���������k�%�+ǎ �]�rqoG�o�7�7��FY��� �A��`����%:z됏|�l\���Q��>'`$+�k�M�,Y��w�!�{�rE��n����4����`�,չqlc���Im�|������7��
`�c��Z�Jx�Gh����c�Hhny"�yT�L\F��mb;�>�*ܦY)�I_"�S:)�1 _��&���F;��Z Ht\� �_�};��o��,*���i�z��>���'�����9H 3i����3��P���E�{��Q��2Do�v����$��8ϳj3��ְ�m1C#JO��C>���E���Y�M6|��.�͵=L�l�	/P��:��mX��bU������ZN>����׌+f71���5M݉����%${nǴ��Bnp0�tM��t	�f��1!�dMx�3mՁ�G���!�M�T������=�W@yL1��k4ܦ��jL���v�:pO�P,F~Z��Q�ik�T���.a*6�pH����R�rCjc�#�5��?�a̯߲4�2�=���瞽��U����F��)~��/����ow�z�oZ�y������R3���2����L��Ɛsobl�jW3����#8�����,�rYr������)3��ˉ�?\�n�&YR��8���ln�������b���?�UA�o�)�����U�ec�TԲ�.:L��L<��Ã�c�9��*S�b���i���������(��?=��_EN�����Y>'����������r����N��y��:��2�Hr���Ŕ���9�5��l�EضM��l�p��ݮl�N�#G�1�qێ���o���;��hK�'4=���?D1�s��Ǻm����aE���v��i�>yt������	�S��i�*>�]��]K���(;�~�q����=�n{������Z�G�����x^5��9v��'�9���b�֭�qnM��Y��l,�c,Z��I_�##C �u���K��^e�$������6�朎�r�9z��8�h��2 y��2�t�+��٢��%�˫�|�<y6��zqm�s�&������G����O亴Q\��{+�{�rp�?<�K��ﶂ��K��e��M{�PI,���8���)#��69Gy�.�Z@ܓ�o�WL3�ޙ-f��t���:��v`�� �v<�ܫ ��M(����nc� $M�����Mw�a2ht�?��(G����ȠH��f�0�����q+Ȃ�A2n�m>��e�#^Z=���(f��%
,RB��\2�D1%x�t�f&�]e��him�?:6���n�0{�Ԍ�X��qqō���)�T�6�Օ���X[>�Dױ�2�8MWDw&)���O؍5'����/n���6�U�*/�jr-�@��[�<�M�a��@���3��p+����I?��
��Q^5��G[�Dbۋ��O�Ѧ�!��m��D��/%�ۣ쥠��Z�wإ�
O�c�����I�ꡆ{��S��`��e:�Q�h���Q�S��iE��7R�������i�u�g��y�]8�������?̂���_z��_>�M%���|V �	�a��s!�X�5��v�E�B���8!~�I������I��,=��c�^ceB��� ���W��b�7΅�G�?@������ja�[0��l���k18u�j��=T�`��*��
a_��dY�)�K�2��|eoc�2����=.D�K(�a����*6��_LBȯϏ�}�i}ⷔ�琜1��-ڑ�6�ƚ؇���0h-�i��ם�2�qp�)�m~l�E�
�Oa"?�n &Z��)��фZ_Z<���R�-L���#��F���¾��*�^|��u�u�Q�t5��o��4]��@�mL;)`l{H3B��P�u���������
h�&����<��8�
��#Tv��1=]E��E�9X��i��U�ɫ�C@`����ŀ�l�-*(،��������G����%�'��9y%�a��c�3[��E]�
���,4�4�sЧJ?b.��\"��,�)V"���`�h�� �0
���ل{�qM����C���D�t'@�P�; �5c(a���!1��f��l��"&�ٚ;���� �ۄ媢Y��Gu0V�JA�s�I�=����$��'�͏��t���ԧ��M����N��c��.Ǆ��7�͂n2�M�j�V_��A�m~����ئC�Z�Fmx�,�m����Q5]|��ʺGo���^'pS��,#�?:���C��}w[����?acv"�lBlˣ\2�#�Tl�7��8=�PI�Ĉ�$ ϲo��cÑY7Ӧ��F=-#H��~F	��6,S
y��@�W���lP�g5�b���;>��W�CY���#y��	����-3Jw��r�@�R`��@@mQUm�88d	��'��dt��u�鹌_�kz$��Ӂ��ॉA���)�1#�$})�%@"8�ط�#L�,��7�xvDht�e� ��ZUvb �8�"��G�PÌ���׺^w@ka�C;sO��������d��ؤ/�aJ�0pA�LV���t���p�=rʹ�.��zlk��RG,���\�O(���Q��n�f_6`�`�
Ν?$����B�dn|H5���I���ф��!c�u�#�H ^@�D։��C��y@�0�k�k
����*8� n�X�జ"v�p������g����&CZn�rq��k~)�$�<E(jS�!��͇��x�4UA�j$&��x����d�Ü�����7�3�sw�a �.&ȡ�y1� �BDW��_�d��z�	�������;v�}
�S��Ofr���_&����]H���]n�{|��+�]��?��Ͽ�Չ� ����fRI���Ŗ�+|zIn5[ieqi)�j.	i!'�4����Rs)�V��Rfi�o�3Bs1���ѻ�O��&G��or��0�E.s�D�2�w�,p�h�'�Q�׹��ݟ+})�K�H��t��O4ʽGW'N�{�_���7���0d�0߹�P��oD~�悊0L�;�!�b��{6���̳�
���tv_�y4N��O�����M���/�p�+(��u�g���?�׭��-�o���_�G������|�;����"�s_����܀{t��w/�����cwz�GS?��ΦS*��r:��9̧��t����%��d�M����$dpfQ�!Ӓ�5�*"W"߻u��_w���������O���~o��O��+�I�����&#���~hc:�E~��4��ׇ�?��w�������Vek3��D�� �/p��M"��^����Z���To�W�E�!�Z�R.k�Ţ��m�W.��r�t���Y\ܾ��w��p����J�z��~�9��ج�J�~�Rsz\��[ک�V��ݝ�#�QB"�-�������*݌�ې�W
5�V�W��W�����}�Au�y$=�ֹS�5Sw��VFǫ+�����u��͆�T
&���Ʈ y�t@�����(T�w���Z���P����u\e��/�w��NA�m��N�R��$6��ԳJ������Ҡ��;��noE�mkR�o����q���V-E�V���X���ҿ��I���{��moWXr+�^o�MaJ�ԯ��ne������ں��|��,��ݲ�\kJ��%�&���Bi����Y>Z�;(t�{O:�{	Gz�q{�'������Ny�d鎎]qe�n�~}��A����T��'�C�Z��`�#W[��d�Dج'7��Z� �ܷW�q�̂z�SwW��
�C�z����{bO*$�D�w�����Z{Uv�'9Gj�	��5�'�.��n��1���Z��9��k�:֓t���+���ꀲ.��Ł��з��®,�+.�_Z�3G7�{�Y�f�JU)��������]��d���[�n]\5�C��ml��{�l���Z��g+�QӐ������S�i�X�RZS]�z�N��@MV惜fJzmr\=�H��U�f!�Jqg�җ��:S�v�xP�4W�.�'ߗ�+��6kS�h�
���]�яv���jC|� ̆��]]��Xz�F��wvv��jv;�f2R>����/VZal���`�feۘo�����:w����2׹̿���O\UPLQ]U]�m{���Re�s8��<��="���u�;�]6����F�m�g��sC@�!T��{b\:�b8�:�PŐ��!�frltu>��k'��\b���pF���ם>���W6�L���߳}Ha��-E]�i�D��yU�V\�k[VC��V7�μ���nЫ�#""�!d�����c�CMZm�g՘Z��A@(T��/b���*�f����N����0غ��"��>���ZҶU�g���RX�+̈a.��AR����H�tշ�+�4�j��qm�\Luב�FcsR	P��▵V���M�1��(B��4k	q��������=M�ti8�)^"\}f����%_�u�FΧ���+saa	R���Z���ڴ�`��4�����:�5�^e���)�ϣE瓰S<�a�5�͎���}x��f�˰�fvn��[���=�Ğ�	=PrP���z�$�</������$��>lW�~�c���}�\���H�klˢ�bQ�(����vF�ɦ"�i���� Q�+3��S"�J����x2���������|<�@���.�����14[��;�@�	^mX�h#5��j�����T78�@��P�I��Oč�m�qe�3}:�X$�b�IL�N1~�VǨ+��Z' ��vc�4���7�<n�)�S�^v2l������_,�w�W�/??���_$��F��.�o�ӯ8�Ƨ]qr��~s���*���[��������[�:���ߕn�+��$�n��۞��N�](�:��/
�����\V���w{u�������t;�\��_����������¿|{z>9���RY}���u󥨼ia�6Ys�
T�K<�"�[Ƈ���я1�C��{'�\/�D�寘z�jV���\�sT�9sA�ԥłC]qt���
�>2p#!�s�%�4����`!���Ca�X�FÂH�j��T�5ɑr�_4��H�h����ڀ�"jc
Kv�Z�p�Ԇ�pS�uG�>΄e��w����ܙ#��L�e�W1�*,[�##M��~OH3<�<���$dZ-)��wa��Z�r�e�i�2%?`ڞX�:E��,q�<0�v��*�|h2Ro�gj�O��V���	��n��6b��i��K��n� |��KZ8�c:�_��j������������4��#)���I�p�����4\"��P�zrI��SMY��B������������
+���@���Q �Sux��ЩW�x�7L�{;u$�T~�S'��1��:wFB��ݡ���cw��4���ݼ�����ms��ħ�p��B�el?Da`V��Ʒ&�z퉡�V;}^��tW���c3����W�<�����ִO#s�Ԥ&3+�h\�������=!�e&��µP���kםe�rZ,�ߜnb�kM\�+��Ɵx�"e����SB��R���(+�Z?���&�Zלn����+Wͱ�,Y�62�b�O�e_��V�8t�7�X�1W$�b<g��#A���X�58������w����h�P�$��n��n��b�����l}0�0�B��6�n ��"sH���~�@��Q��*�@��9�V?L��;�V"�:���]�aZ��ԸE1$'zS��DmbNz%��x!p!�hy��t�G�}�X ք���Z"ب���ݞw�"6ٗכ *$�<7�@ǈrO@�����Ċ����c�EZ�,�|yS�jDq�[�_AcW���=���">.��]#Ġc2}��v�m��L!|�.2׋����������+,���=�J<>���c�z��4��:�I�b���
�?h��g����W���tzҍO����O�褁���F���0ZW�a������2�ug�:L��)|	}�,�9����%'��~�
���D~��ߟ��=������ׅ/���ۙ��~�&Sk���g艳I��J�>�����Za�e3��?4�&�����}����}�Vd�\�G��U�ѽ��~u:]���i��b�Qx��mː��E2�T^A�]�x<c��'KJ��O��:��!a����m�{�r�y�wn���(������?����S��қҟ��_f.�x����j�;?a���w!�&�������Opl��|=t�c��L����u���o�-H��������\�?���� �������V�]�= ��Ϟ��K��?d��Iˬo �?��������Ȕ��qWd��g�?����#��OF��;��b�?$�,ܜdH�H������$z��`��T �6@�H�x����{�E.�r���4���F 2��/[����{����T���x��\�����?�t����3г�#�A.�?�_�T�E�,����l���ǱK���Oy����`@�ȅ����C�����PmT�ն�Sm+��a���f�T�Y�Q�����/[������y��  ������� ����?���ȅ��)��2B��o���h�r������l���ǐ�����oJ��;$� .l��a94�R���h���xX�p]��"N:�g���wa��$L?�w�SG�#/�?��Og��ْ:[�}M���Xe|�yh�`V�c+�4�$�S��k��;��A��JZDcQC)��р�-:~��
7l1�t��̼���;��.�Ev�.���om8�C*�dޔȖ%����Sk�!"�+�gXw�X.��y;��0�1�/����]�T�xΐ���f���4��9@�?��!��d�L����l`�ËE�����!�k�
*�+�&j��,�T�ӎ�2c��'�G���h������	�qc�6���vV���L�HטHix#�l&X��Y�)��9�e�kd���]$�ˑlά:W~�΅־���{*r�a��f�L�c�qV����A.����� �@����_`�迬�����y���4�h��+�׸�ՏV�E�ϭ�W�������J��۷ȳ�/"{��сl��`t>����*�0L4�~�[��ܴ�ΠaϺE�̢[���b���B�@��|A$�\�N�5�j�Keb��Yk�ֶ�&!�F6�.�Vg������@s�\i9�-\7��b}��j���XVkW�v�+-h\'H�A����A����;�|Й�����0��,W3�D��l<�������1q}���r$p�T)�a���}QZ�+�6^jtp[\oI2n8"l5�[�i����;G��߳��T���?��5�H������[����i �O�����K*H��A����?����������R�P�5wH���u�W0�����`�W��+��5S�O^�����T���%� ��e�<�?�\���SB���y�r���Y�O ����������������h���[ ����_����6��}^�\��{����O`�������"�!��Y�������'�h�����M���r�/��O���̓�2���Y�?
�3�K�O��?(�5 ��Ϝ���_fȞ�AfH� ��?s��/����RB~���d����]�?``��T �?�������������� {�>�����l���'@�_V���s��ȅ��'��?����?�'�g���Ks^�#�fb�#���t۟������Ǳ��S�gښ8���Pt��)��	�z�[��Y�B����[N����o-�"Y=��l
�ݰI�f^F���[C�K�S�V12n,9��\�o���$�����$��r@Z1�ݬM�CZX0"1>��H�dh��:!ZVBz3S70mk��!=UE�-W#	fcI͑S�!��$Y��.���=��;��ȅ�C��������(�%����/�O\���H	��P2u����S��?�����#���?��_6������l����?3��Aq�ԑ���3���?���/���_F�^���]�W.p�Y ��������rY������?N�ca�瑖c�e�`��zl������p�v	��`��=�p\�"]�L���s�����0���y��A�:8��͖�9آ�kB����*���*"�[���Ӈ�E��yUV�c+�4ߠ��ೲ]������@TuZz����7����.[L2]m슻y-�6~�Y�,a��b_Z���d�cB���,u�����Ѿݔ�`+
��Y-���y+����	���{��.n*�<g�C��?�C��?��I�l����_v�����!{��~�7��g����/;|H��0�s8��MQfK�Kc�2G�:��zTQQ�WZ�qiˣ�#unG,��],<^��g����H�f�"��B���X����Q���~��Wٍ���3
i���y��M�I�u�3���G����BP��i ���Xo�է���,���_ �+3��/���@���/���3A�A`@�e������?������ �٦��"<2���],���뿛�R�=� tL8�(��pmM2ZZ�V�jQ��8T��dm��xXq;����K�3ꗩhG�zwe�XC.�moOX���e����Eu�`'#��*�D�W���^ݫT�{,���L��	�"��+���wn͉�[��X5r>\���*�(w�=��������ӓ���L��g���I:������Ci�/�b��B&��f��W�{7���.���Ksj_�E�Q-	/����mI��)rݹ��Y���2�1�'���c�?�E��� �$�R�,���h��Q#����t=g;�+����R'�K=��]����Y���N�#�cDv����� v'�MP������Q����/��p���:������H@��fz�T����_,AA������`�����/�}��	؈���	�Jy���F��W�$i2��_?]��'2 	��
�4v}u���� �Cį��kk�j���f��w���L���8�v��[e/R����#m������-���h��o������8x������i�;4y�������?��$����)� �.�M� � �R���@H���/�l$�8M�$��GSBP\�FL�'�@	1X�O���������_��Zl����?��Y�qL���d�����tN!�g�4&���|��˕�V�>R�|�V��Vj���I���D���USP=��������G�A��}�������������]��!���_��]F�������X
�?
�������OD ��(n_��x����g����:�?�?������L���^�@�����W���@�?������߃��?����*�����U�_������y���GD��?
�x�q(�dP����$^�d�P����\��d�\�5hu�ޔ���~���)�n)�^T�̥�9(JL�K�J���1���V�$K�1 �E���h�l&����^+v2-�lt�?c��ck^ߔ��'O�AHu��yYD�R�\D��
�����35��0��ԁa?��ׁ-�v���$]���j��"1��T�����"͊��`'R�_,��~1:giw��f�Y(>�/��dS�eoMu��Y�d/�{��gk�E�M/��u�򘨶�^/d����m�leO�_�[i�$ު�ԕ)�O%^���c��ڷ߈υb��b�o"/��^TF+z6��`��r��i�^98�6خ0�ÔӜf�}�����"�n��˪Ö}����g�y7o.��^�Jf�/�Kc�u�]#��rG����2YW���e���ݽ-�k^<nB������oG��ɏ�a�w+�E��h�7��!��_1�֐���_;����3�k����H���?�� �G�?M����"�g�_�����֡�Y�sܔ�s>�f��X^�E�_���:����KQ����Ԑ�OZK�ט�BZS��zxa�M#�t�Қ���x��I�����5��5̛K�-���T����!���~OS��w5���c�Ǚ
�����^�uQR�q���8s�w��5�Mo�����l�#i���qK�M'�!� �f�����)[�5���6���Y�Jc�8R�i{j׺�r��[-k��3^Ź(������r�0eCԥ����K�����Xm7�a�A����6k����Ap0������T�g����>������d�Й$4\��ӵ��Z:�מ[���73=2����9�۹�	�4�0��#S���,�w�-��ޮ�P�����t�!�{ 	�J ����Z�?� ��?�P3��ω� 2������?�C�����u;�o|?�W�c��i~!X���-�ϯ���J���4�'ӻQ�nE �� {�M>\��\�� �i�"v�i�?ϴyw �\0���>{X��u�I"�������=Ǎ��屭炧��8�ɂ4�q��𙧳t�h�.����2ߔy�2��u �s!�{� 8?ӆ,
4`��X�˸GKZ���R�lIM�WӇ��tE�H=;(m�M��dL�+$�U��/fg��wx�YȺ8�rⱵ���(j��X�w{����x�
�E�ʫ#Ϯ��%yP���e�!�n�_	���v�W��_5�( @L�?��W����?����-�?�������u��ɹ���?z������O��?��GB��� ��`�'�x��Χ����@�TB��Q4�BHpA 4�p�%���A�����_�����ە�|�f�����8�8�To�<.ۭ$���`M���wG����1�ť�\�2�W�2o�I�ѣ�{�̙i/�i�:�䩷v����Ȅ"��r�nKs�d�H�47e���V�������Q����C�*����_u�B�a�Ge�A����������z�A���Uǯ���2�Sc�s�vcml�}��&�6��[�~f���gq���o��I��a��.M��p��n�ǳ�5H�S��@ϒqj�ۦ;9H��V/��椊���l�{�i&%N���]��S������z<�)��VD��Q�G����u�������/����/������ ��Z�8�0��������4�_��I�|Dɞ�c���y)\~���]������B���K�Jl���8{ˌj�uw��5��Bز�P�l���[�֛�ZG��8j7�X�.hψ�̘�s�r�۔*,�<�f솾�v�	��T�{�yٷw�6����ɷ���ۖJS��]�I�Җ�:q.��O�zd j�,�'�zI��'.�]'�.�L�y���a��h�(^7D��d]�N��Z��L�xR3>��A�8�V���O����P��g�n�c�X� ׉8[,��X�<�hc���Ԣ��7������C�w} @��"<�a�k�Aq�v��?�����	�����C�"�?�w�)����U�?IР��X�a�k�@�����J��W$��W��
�_a�k���U�'��#Q�+^j
�����A�I���@����N���?�����	P���P�����!����V����_;���������+^�D����/4��A���/���_m��u���A�?�E����-(��G��5$���:�?�?��ǂ�� ��Á]A�����`���������+���W�?��h�?BB�	�0�i�� &Ȅ��@��ei!�p��*��8Ȁ"ɘ�K��X��Y���?��@A�'~���}�2���wH����h$ʧ�U�Sk;�/�e���I��ڭp�ɔ�y8��s3_몏�l�6�^QRo3[��q'�頷��#]z)�J���t]R�z;Y������Ԫ��J��ģ�?� ����8�'(��G��4��A�I���w8�E2����Z�J�߽��� �����������?��,�Kb!���4�y<�����M�q�RL��A$p<%,��)QG��'!'M|
u���?����W��˴1����u�t�m�5FN�mj��'��y�Q�I��O�����N�M��eS[	��*��Ȭ]*!����Y��ox�;��4��=\&�h!�ag2�e#{7]j��8fky�i.[��+ux�C��:���h��)(�������QP�'��������U���_��?����$T����Z@�A�+���C�	u��Q������?�*����:�?ԇ����{�#�D���0��?T�����H�C�W�2�Q���v�W�g�����P/�|$>�:��G�������p��?����9�α��Ŕ%c���Y7w~c��.~����u~k�,}ot6��oﱟ��~_s7\C���I������̶�~��W�#��;x�갺��g4J��KzV�Eh���)ݛH�p�GCum��e*œ�������'��wBȦ(�����%yP���=��������}*��.$fP��K��V��'Ӆ9�v�EIVS�q�3��(�<��&-I#�z�d_5�[�.�g��9ZY��`�ÍZ�/� ��@G���W�v|9�������<����G$�L�aJb�����Y��(��O0�	�?��'���U���������k������Q3�o��/�d�����u����V������Co=��)��|��re��t`etQ��).�~jʣ�yR.�}7љ#/�i�.WWw~<�Ԟ���c��]?6�T,Z���vy���Iu�����QT��_��?�NñT�Cf��Ik����QHk�uW/,�id�NTZs�4�9:��^�?��?��ys)��2>����s?�2�LS��7��}�1��,��c7}Q�uQR�q���8s�w��5�Mo�����l�#i���qK�M'�!� �f�����)[�5���6���Y�Jc�8R�i�y�����vo��%�OV�6%1�q.��\<y}�,L�ui��'钀���4V��j�Dz���p�͚3��htL1��c]o�,�h*��d�0,&+�6t&	����t�7���$õ�#�(��Lφ���+�s��v�lE/M�;�����>;˴�c˵E8��Q���xP�	��P��o���}�K�����׎����`�#�$�J��4$�(e�8�Y"fx&�yg!L�����">�(�
X."�0©��J�B<�aG�����?���	�r�q����4��~�ݴX�������JԱ��ms��BU�6����p}���ޓv��#���+0���L�������e[�-)���=�<	I�)R�aY�x�V E��$>vG�{	�B��P���^�jC�C�|�v|6���Te|�<<9��>ݴ�_+�9�J϶
Ձ=�i���I+ٚ2S�����q��M��G������0�o�>]z���ѷ��O��������.=�����d�9��p�����^z���=]�����x_�ǵ7���AaЉ���~�4�˟]�X5Ÿ<?�Trf�����N2�f�Ce�Jhژ��w{�ƻC���F����T*7���� �ؙƵY=��y3�'壾����8��'�����VJg��yn��m�����ٮ�>Qz�B�������s8�����ti{�k{�k{�k{�k������x�gk>Az�8{�?����i��w��A~v��5�:��e��S�䦚�i�������'9����z����kk�#w "<�� D����; `�*�t岴�R��%��w J��f�}v\J�9q���W�H_%�έ~��� Q>~7����N�}X�����'��O�����k����U��읃��޺�k8��rp�L"���K컏�����[�; ��ʓ�2�VyP;(��)]npa������`�b����jo7�ձޱ��QdP��m|jf:M��=;�O+�����i�M��(����C��DʟD�śJ���R�}8N[�� ����*�7�?�5�s�Z?1"f���ˇ�ؾl����%�K����N+�|IwF��Q�������dpSn��W�w�_���h��|JG��6���|!���t.[�����^��9�Z�`�z�ެq��t��1�&m��B�G^D^�N��)v�)̰Y��2������4�ʐ���$������ Z�i��▆%1Re}���� f��A����A�1�l^���쟌R �b����� v�4�-R5GT3�$`�����6B�v�L��a����h���	�AM�3�6��`X�J�?"a�L�18q$��|F���1��� ,�a�P�;H=(�r�3Ν�:�}��؏@�g���f
g�$̠=�A69뚢9 "A��D3��t-	O�Ӯ��*N�)�!.�t�L4P��M��E��G�VH�� ��n���Z�b��	x9��l�]�9`�7ŶmQ����$0U誔�sGȫ6��jS_��K?��Na��Ħ �}�z< �43���\eP�5�'(Q͑�f�Q����T���NX�Ҁ���Hp���[1:Zp1D�;S�۷�����8�	N����	d2Ԁ�fρ��>����.t�o�#�������"$�|K,f��Ѯ�>�?k�����M�}J����Zt%8�P6]�ҹ`i(���7�Q���}���ڃ2KQ�QkE�ׇS.�>�~�Μ�|��R )��i1�J�!��b1�J�}q�裺>� 9�Q_�R����ծ��t�_jT�J�⩘���R�}6]���3�D,wԃi0�3!y�+�~�?���T�*�!�:��Z����E��чVQ59��8>��+o�_�C"�0A�}݈%�!�02r	JE�]�t��N`Fz�3��J�9$l����[���ތ�8V��h�lw���8�뚍`�s�!GİIJ��t#ً$�g�D�[�:����c���JH6y8q:�y��dIҠ�P�[	U�f�����r	�@��n#�ݹZ�D���WM�Y1��5�ӻ� ����l����t2�M� ?�O����%�k����HY �{�CK�0��Ft B=����3u <!YF�ŝR�r�<O���֘0#�q�Y������:(����E�tq�<��'��$������b���Pk�S� � �Ʀ�<�hخ��v@��q��CS�����$�g����5�����m���Z��b���L��^>G{�^2��,�TM�YVI�=Ji>��c��n~�ehO�V�I���=�-��Sva_�X���[E�w<!1�%�Ƶ��# W���>
M7��Zf]�Ic�PJ�|�-��/)��}e���p�]���k�Z�trq�<<�}��쫬�V�w��F�Zm�:��d��[Y���;���Q�������A�d�@	r;7�6��~������T�tr�iի�r�^֖��ۋ(��oIh|�@&�u܅�YE�0�Nb`��3Lؖ�����8O-�YXx���֜���'Qޓ�\��"�z�
K��/�!(���XH��V�)�/�<_���ˮa}�t?��4�5d��z��b����R�QiV�Vk��p���F�լ7������z!�kj%,א�G�2*�٪�k���pYO�V��$��[�Y9��G�N��l�/���f��z����EФ7��A*(@�B�+��JݣE�A�}���B�zu;�R�&�VK�R�ԩ����;�W�g��jY�I�yR���+��v�?UR�UMbŜ�2NV ��}p��
QN��^Ҙ��d0'�J�}�*����5�O�������g�|�o���8t�����`��\5��7�#��<vY>��rw+"�*]4�Ș3�\���勳�	4�8@��rT��#�^�b��[�O����͉c�\MW���F'����l*;���-d������+��%h�"TLj�������A�=���>U��>V#�vDp �&wi*�q��x(N3]g�:e�;Q�-7H�XR�`���df�&T����{�W��Y��Gj�]�Y���i��O���[��e����GI������v�g���]�ٮ�l���?O��#�Ǘ���T�7_ �.�l�{��=�N���jN��5n7oc]��B�0��e�����{���o��f$z�����4H_�l�0�2��dli�C��{�ێG��\�A�*s���Ĕ��O��"(���r�����_�Т=~�Iq-O���Mk����yE����׌�|�9���<kWj&�����Q��d<Q�	�v�.��䰫�B��";"gmn<h�6z�RFD���	&�>���`ӈ��F�8��uNk��������q��@i�C�$�$����H#;�B	J��I��k��t�5������(:����mc��s���i���r�9�O�����ç���GQ�$�_s��H�SF�m��5��34:6_���xi��`��5��"X#��T�����)�ͧq�'��l��1RP����/�g6�?�^�o�_�24I4�=�/E�,��gl�ϓ�O�_х�⾆]�2b ��t��i�c���:�t�:�Z�K%CqR�������p=c��;#�����aj#�2��T�x�� �q��?S�؁��V� Ti���F"-j��d\talA��ׁ�$;/Hl��$��7�&��/
Ͳ�l����ǯ���I��8h����o����$6|�{�^��Z�՛�.��Tԫ,6#�1D��f���lw�d6U�?	HȰ����w���#���aИ^G@]��(B�b�a<ői�i��v������V�L�S�`%1x��!��x7����u2��aW� K�:�?�\��끎��c1��	�\��A���P^��O�_�.�ba�j翁���T�2�F{Y�^J��\�����ooȻ���Mh��dM�)�b�V�l�p1�_�5��Ϋ�~	΃!�4L\��k���u>H�j%u��t��!#(P���I�y@� Uv����L�㗶iD��zQ�h�D��}+2ob�t�,�[s�ڈ���3ɤ�&;�uR�r����!��O�h�b'V��?Y^��Q�����o���,�¿2C5A԰D�.v��M����+�P�v�bT�#-�s	?�z��v��s[������˟+Y�K楿��s�ګ�����eo7�`�o���3�6�ǚ�1�i�]��~���ή�Ƥ��@�X�u���9[���D��+$)�ô@�����RL$`Ҁ��o�DW4�8�w↍��G��٪�U���v���Py�r�3�tvS�6��s�$�0��ncER�8�}^�}�����(X*����d�|��T
���nw���loW�˦3,���wU�T2٤BS���K(ݣ�l�pa_E0�ʣ`mk��~�|f�x�#[j�TJ�j��:��'��8�����U-���(�� �3}��Za���x��Ib.��	�i
8Ǯ�%��gK[D�ɒ�1~�ag��=h�����إd��`,3�0�뫌��X���-��:��Y9&dIUDwfE�f;"��� �x0'I�1C6�Է���m6��hh0����B���j�L��a#/�n���}�mZL�\��آ%\��V�֭������O�tz����{���h��I�����$�d�O�>u'�ie�P��7���R��W`�'��綿��i����tf�����x���������������?����&ܺ}<����`�1����	bȖ�9-$�oS� A1���0Kr*�dN��I0Ҋ��l�%�m�<�W��M�[jw/����Q����D �?���mY�ۈ�36^��wi�x��1��aʊ3��T�,ﻕ��#۸^������{�S˳�<��;��(����z�A��O����G7"�%���w]�~d��T����&U�g
X{�K���d!��?��m��=J�q�O:�����}�\@��Ϣq�
T �D�b�7qv��1�^w>Ϯ+��Ii����0e�6��b���S�����������
���(����M�E������d>��Jҩl:��_6��n��c������^����'D�<ʷ�j�>�SK(ҭw���A{`;��"d��*�,����6Sf ��4�SD��s�4ul�g�K��.������g�Yd~1�����E�w��*.�ء���p]���Ն���
��CsGsU��~�E�kZ�[����.�� Q\Ү_�4�ر��%�	|�n� �����V���x7	Z���}��*�:Ѹh�V���1E94�{��J
H��3gG���������J�;J���5�c�姌x�W^Dơ ��{h��J���{"����q�W]A���x:�9�E�厺	-X�H��5b��%"�H�	��@���(��C �<�(��<��5��1����	��G���UT]�q�H�@�_:��z��W ��fy���j7��<Ym���x�&@�=���[�B�k��>��ki�ԏ^�M�J ]��+�6�z��M�xZ;-�ڑ٠R�r8Q�|�@��k��	��I��6�;/d(C����9�"�)4
xlԋM�O�x�
"(�3H�$,Ӷq� �1w[]C�P�YƦ���qhMCF����L9��<��4^f`b�54
�qB�D�;og�R�#�k�7��*�z�1���s��3���_Z�Ǣ��|��aSQʹ8�0����?�b1�G��\3�K�W���/'
�M��I�0������R��ĺ�dW���@�Q���(_��^���/d�,"�.���l;|Iy�:��n�:���8����0�3W:��x����^�v�B)�a]�C��0�����e8���s��G�2��ơq��,0��p��ސSQ73{Do��;Z� �3k�����\��	�B��V��/{��8���{g{k�L�4�m�.MiwA�����Zi|K�$N�Ĺ�h�8���qnN�d4�y@H�0Z@��o xCb%x����1/�Њ7@<��[�.]U]��i-uU���|��������<ve��,3�݇�|V���ֽZ�
W�Y�[ߦ@�뵡���m5��xܱ���j�my�0} 2۽�-�//�ũ��7�y����+/��
�%��[ݺ�����E$z�Eu'���N\�D���?���?A�VO$�͓�Zf���'�/6v�����<�x��ޚ���j��e�2������`�4�z�I�d��)�FPr����)��)���T�u{^��e�<&X�fcePچ'�/6Y���>�R�tK���
+�8�)?sr<%���nD��%8w#�-��<�"|^��}�W�]��\c���6.������!HA"��?ǃ�o;������Wn�9�����_<z��_���HV1��MQ�R��&�F)�h�)CIE�#0�NE0U�(���:��zǡ߻�w��0DC_�l�C@�eϖ�^:�: ǫ<�[� :��s�����:y�Ƿn_���YX'#�赃/@`��=�����u�Tv���ކ��)خ�הƉ:��u�wW?��w�G~������.l��,���	��N �D�?�S�����_�G���C�_����?���>��w�	������[�n�\�W��y]a,�ƻbD$ih
�`�I�����7"�8�]��1�Bq�6śJ�B��*�C��~�ǟu�:��O��|�������~������߆�w`�7a���l-LC����Λ`��	}���֛��q|A,��}v����K�e���,r�\�[j�,�u�i�%.Y϶��b�6�TB�G���pt���A����$�����K��7z;m4��]uyrK���]�yUdz���r������s�ifN�b�:�.�k�[6[�I�2 &�);�����U�6K��~yk���jyگu�Y�k��|Չыc	�Ad�0=o%[�n�������81gQ!�O���i�[ªeĩǋ�*J�b�q����i�]-��W�uީ&V	�YZ�$#�hI�$��AGB��p�Ng���6҃V8�5�v�A�?J!s;��\���MǲI��O�:uК�b�I8-�/nE��d�b>'=v�+��uzlA��q�ļ?h�s��e�C;<���E�l	�]��m��'P���@tA-�;�FL$�қ��V������׹�{�<-��l��Ŷ�T^m0��&>�"1�}�5T�:O��:+�+�Z�	eR.�<����_'����SB_�y 5�hiT_�����/�Mqo6��qR��8k�2�Y#��g�
i���)�I*��}I*���:�<�fZ�&	�2p���1��;N�}em�����{�.M(GSSFB�iAK���T�j���m�k�r^N2	+�)�H3_lV���)��a�"Y#k}��f
�0�<Q��Y\wRmYf�"�Ł738��w$ol:w��LwXS�$#0��'���M�lv�1B4�$��e|6ջN�|�$�$��>��U�*s
/S�U���k�\tJԄm�uA/�)���$g�^���^pD�@�$&r
l�X�"'�L1O_��y�\H�(t��'��p�D)p��	m�?��H�b�s��dj��g��Y���"v����Xnħs�ɞ������E�d��DO�I� O���\O\O��������1��|�L�#SM�jH&bd�,��̜ĄUN��F���P�������@`�����٠r�!���NOi�q��k��4⇬��f��)V U�3�y%��L,�U���AT�!N�%�'��4��`Tc>F��pw�#��91�Z�)c�G�d�;�@W�$=��L��j|<�*D�V��h�MNiv�M�;�]��Y�1�����Ϻ&���t��y���W<�m��mN��-������v��B������i�ڭ��k�Π_�^um˃u����W����JO:p�s�����//C�]s��%�A���E�ݷ�}l%��~������܇������^�]Je�Ke�X�vt��G�cʳO�+D��������e~��k�Ϣ���Ė����M�s��h͢+<����5o3XR�������4WD��f�G��
�T��Lˌ������a�K�Rİ	��#�9&X"��9-֖ E��$ՠ�H&ۅ�z52�p�f�Z*A�ݺ���qǞ�0zm��n,�B?Y�!QTd:�d��B�/ĲR]3�����U�����ܶ>�ȴG����.ޅ�K�2J��w��]l�Cl)D���\�θj��k�i�ڙ�)pBP��1<m�FE�ur�x�[�n����V!�N%�j:���Ҩ�):*p�]�g�><��&n1���L-T�X��NbaU�Bx8�V�"}���/�4��(�7��TM��ؕ�q:�G�ّ>n��g�������k��>� ��ti� s�Lk-�fV1X�����Ug�6?�p�Y��e²�۔9�6�^Owp�����`����{������X�_M��mr����{d�c9{�+f.�C��<Δj�dY-��:eC*���<��0��Ӛ]s������@r�5�v'\��D�:�dD~t��h�v��2�T�Y����r��Vr����S��R�Xb:���8D�[��kӉ�P�8J:O�gDu��`^Z���Sj%��ⵒ�L�;r���r�L�)8]eP��4���	�s2�'���0����5sl�@��NF`Tf%�MΥo=�N���Ή��	�ٱ 3��Է*9�I7ZJD<��8un������ �����	��#Ɲ�0�]�Yp�_(L�[���ί
ضy/(����%5��C#�,�x��Sf��SC>w�<;��e4:�IAG�yH�#�IS�j&�3v�f��+��sO����D��@k�r�@!��<��i`�EC�#ˑ��$���P[C�*7�)��m��B�At,�K����2]��J����I`&�kH�r-L�(��)L��X���!��4�k|��̙\��e����,�d�襑c������:��^����9	��W?'r�2_�������J�k#{h,�#�`]���]o5W�F㑷���/{�h6U���7[N�7�W��Ǐ#�<~�`S�k���=/�k���6z��y���BVRL���!��tEoҥ^��s�&��PF-��iS�D���jV������W��)��:�`ǋ/r�Gw�.^�T����l6#A8t�y�6�'�"�<����_�����C�1z�����������B���.p���D��J���@����/���	>Z�D=ڌ��{눓�'��=ӋJ�S{�Hi6�X�3=r�j�{����4���O�}�ёϕH�o��[妁��&���>ڎ��^�+�uS�{�����z�Y7uC=�n�zd���>�z�ܻ��+�uS_�#�ΨG�M�Q����Q��'�����?��a�a��t��ӆu�.��c�����O!�� � ��� ���sk��z&�����S\S�ߔ����~�z��v4����E	��q	 	��]`KO����>H��E�]p�mU
��WT�XR���qx�hI��云�����bb���q�V�by���ѽRI�ҝ�m�]��9Hzd8S�J�-]�ֿ����+]gz��S�����"�%m\2��IO���q�쿝 تl���~�_��~��#�o�����=�~���� ��N�m�-s�l�B<��E*��S%I�a�I��T�SF�N��,]�HE��˦91c����)�B�-W�di:?��#�����bgSX24/a]���~`�Nq&��35�XJ�qCg[e����,���J���x��2�u5Fl�Dv�|<sc~?���5��vD�+�q5�/�������Á�w������tO=��������c���ym\u����������F�?����2e��w�I���?=�c����'���������)sN��G���������/���^:5��=@������(|����~�x���!?�����������`�_U�c��>�k{ �s�]�����	��cA�� �����=M�>�g��^��9�?�o'�S��B�+ �"��_l�o/�;g�G������9,�{a���Y���A� ����	�3�B�C���Nb��������(��3��������1�������	�/~v�{a������'�-ٖ�lK�ɶ���}6��/��}����������[����߰'�l �	{a��������q��L��O�S��h���j�����������#ș��8���	���UE�G��x�CH�QoR���M�ьDqM#��b��l�)�=�cL�d��	�ۣ���~��!���������_�:�A̻1�"0W��lcB���JR
�L�_��	��U�Y����Β�b1�bt���4�!�ȰZ#���0�W�L���bY��1�&��׬H����e�3!������Ɠs�����i������mN�}�>��������A���'�/|蚁~?�����������(���Ǳ|-�+2r(U������,K��X{�Wk�/ŗ:�F&+w�uu��ÃX��T�.����%�QibF���`Lf5<H5�������̎w�v�l)���4;R�<�W�~��H��������P�{W֝��m�3��;Ƒ�y� ����ؽ�Q `/
���?M�wN�;��')j'k>%�4��5g�\k}ŋ���������/����/���W��h�A���[�ǁ�Á7��?��O��r�lWM�x�:Q�?3�+�_N�UG��~���V��&����Ư7ۨ��m*m����\���Vw����Zw3@~���Ò$k�qPF����R:�P��&Q.�lcW��:��^�I�!�u9mwm�h�}]��*������[Y�6�:y�r]�x�M�N�����C�B>�4׫]ﻮ>h��c��_Dߎz�fۨ��,�E��R�Q/4�u�|Uuf��z>;��n�0�T�C��Hh)�ix\����7���8�3�BYU�TJ�|�^^��κ����V����Q�V`ҨU;"��|y�����ל���9	����w�?��p��C�Gr��_4�����GA���q '�C�G���7��� ��0��?��G��X��o�?��/L���Ür��{�?��en�?B�0�?�y D�������C� ��_��B��?��Z�a�� ����	���8`���@���7�.��`�����$�?F��_E����'��'8����?O_�����|��ҝ�?���l����˳X��?�����w��(�����E_�o�������
C���!����p��o�B���()���}�x����X �����������_��0�p���b�)�����#����+
���g�6�g��S�q��?���u�Z��b�G};�4j�L��֦ܯ;q�z_��W���yn���)�C��,�U��\��O5 ��'?j@�C��*�ӎo���6dKGAY�6��������F�����2ee����'�v�6ן�٠z�qb��V��\��f_��5 Ե��ԀP�"����j޹8�AcY�*F�����l>�����S���O�Ҵ�*��s�߭X��*+��z�Z23A= �=��<eC_K~4d\'���oc��"�sg��`A���C
���[�������������C�����w�?@�G�����#����?hY(��o�G���/$�?4��"�?������������`�wA(\�-�S�mv!��B ��{�?��c����q���^
'E����(�p��F틼�lĲ���D4��(�З�P�%v"���~���+����[���x����;V�b���a����YScC�5��N[�k���s�Ry�87j�I��7�qOK�����h�Hg�o��� f��t��ӪG�j8ʔҴ�^��{��i3dˍC\
�2vy�$��n/�K�\V>Mb!�p��ų<cK�׮g��i�'�Zy��(ک�^?�鹛���U�'$�����8��gK8�-$�������?
C����[�����/ŷ	���8|��K��`:��m���'4��<�5g�u�Y�a�Q9��Y�n���ح����۲I��|��_��r%g���@%٩k�!��%���ʓ��>��.��Y��~-1�r{�I��*_����Y��
2����/���������+�}�+�g��������/����/���W��h�b@���_AxK���/����i�������=dޖ^�ĺ�x����#���� ��^��q�GKC̶���LJJ�(O��i�G~��Vþ�0��P�2�ǲ��D�;���+�U/)^tP�$iݯ1��l[�r^���<��4��5�I�i��j�#Ms���_�SSu���ە���{E!Sa/9��,�����aU��nE.K��(�{]�s�����r�+6V��Y���e0�.�GV����?�"�jp��2�����k���AE���t=묧�����D�h�[q��lR|Ez�4P��T<0������ߨ�cw��Í������*����9����H���tS�!Ұ��������q�������ŉ��`�����_0��������_@b��(��E2�^O|�� �a��b��d���&2#��e��#��pP����q��������#�?���_�&��	���j�v�:*�(\6JG���h=o���JP�=����l���we��~$��̽�꿰�����;y������E��?����pS�+�,�?��ɿv�`8�K�|�'GJ��<̋��<K�b�)�$_��}�A!0�����^���X��O�H����՞�K����d7���-�����ۂM��X���m\�eZ�����5���WA��O3P�U��0ًT�Z��[��Ѱ�� �A��}�����I���������=���?�������ߊ�~��s�U����|������A�'&|���>��Т_'�>p�����+] �c 	���������\��8��8
�������������:��K���_8�C���@ ��q�wї�[���p�n���1� ��_��1��.����������!��o��y�����������T��R��+�PH�^�鯒9s�l�iNU�R�������ٗ_t�8U4���Ƈ`%$��1�5�1+v����-c|�Fa����?c[�yj�>W_�]�u�*���s��wPQ����90ʮ�?���N�z��1�ȫ�S�]^p����W$e�l����Y�^���eq���b���s�~�V��vZn�Sc,dyo;J�sΜ����2]��Zm��A�VZ���\�:�.��������)r"�J�z���j_�]�zMe�+[�"^����ՑIi��'�sP���d/W�"�j�*�+vce˭�q�͌}Oݢ�ׅ|��Ńk7��h���ɖ�:�;��Q��r���Ko�i#d�vFy)�K��'�Jq�W�I��΍�>�X�px�����uTs-���{�c��5�$���r?햿Z ��wo�7��a�/��k�(�����#�������D���'�&�'��!�������ͫ�^�p��u�)�&e�<m��lc,��M�Wp���/����S9��o��������9v�`�)�\�}b^���rgn�vϢ[=�\�?<F??F����ݭ�y/��VFdk��6E�.&;CA��S�����WiK�̽�8j.c.�ݞ��4�3��������tzu��n.}i��j��*�tg3����8�u��JVjO�q�'3��^Ok�*oR�Z��������ǫ:WU�:���<+wv��Z�j7F{I�4��u�����&�nX���ѕ�h�غP�������z(*�c�6���V���Tň�~o�2:+�@)O�㒤[B�]���*�rl�]�!nVN�4�T7F�+�iߥ�}��F��T��0q����k�~D�?�N�7��b��9 l ���[����_���d��c�� �����9���oX�������ҏ��0�1E���q���SY�n���B���=�6Q��!������F���^�����0p�z�i3~�i�� �N�s[ܯ�)���Qc��1�p�Lz^0?-Uk�j�b�Oؔ��uu���������q'_N��pǰ�$ߠHpŷs �s�=9 i�Q�REUxQ�g8��ŦK��B���3�4�Ĝ��ۛ�C?r M�v��C퍪"�̊b!o������h+���eu�K6%��/�ڂ����Do�vA��Б��EUVY\_e����0����K�������������,��  n������8��?�����m����̝�'����f�]� ��������^��������a.bЧCI�#:�d��#Y	����@�Y.�A�'�8�#KH�	!� �������7��?|��7���fSklfee��Ej�R�t���9X.˪�N�]����o�ݡ����Iloq���T:��Ue�)�aL���wr;�I�.C���XsW������{-6dQ��uoj��B͞n�
��U���C���P���-�зP�����+D�?��(������b���$�?������p�p,e�^^-�	���QX��ۓsǼ|g�i���k���z�"��K�\�[���M��l���h8�)g� +�̱jm��h����y�����n�[[o�86)�9�5���]��SCp���*�X�Y��-���+�}�k�'��������/����/���W��h�"@�����������xK�����?��V���ʠ��ݡ�����/����G�Gmw�v�6��&����:����\��v���K�a�lE�[%~L�����v0�j�$�t�l�����t��\���s�l#.u�Ӭ�	�;�rR���ԭ��OW������U��׫j��]�;-6���S�M�Y,�b�Z+�q;t�C_�}�9g�z��W�%˔3lq�V��^#�-T�p+VM:��V���e����f���P�ЧV��qu�{�d6�:Ӭ�p�1k��63�ˬ4QTv'��P
�[nQ�։ m�����$�?��S��������J2p������;��X@�w��� �CWR��_4�������+i��������W,���0�����B��x����L���`�� ����	�ϲ��v��/D��'��A� ����C��?���0�T��������_��?�x!
$��{�_x���0�����?���+����N�?�>�x~r�������<�H������� �Á?�������_���> ����C��P�'ܜ���WL������|ߧy��&h°!�HA�"��-�r�!B��a�ʻG��������qt����7���oü}�	�@���Ͼ��`㲫�fJѯ](���"~�LQ��д��B�����a�a��S���}����O����a]���y75����H
����2W�q���ާkU�n�����VN���Rc�n߳��m�
Cҿ+f�A��f�P�������4n�g�U/M�]���(���n��V���e���S'�Y>���[��j��O���!���?��/�(b�&���w:���=���B���x��iҡ�?��w�����������Ǎ�������;���ZVF^��r�e4
aK��2bR*�d5�e(�3dfĨL�c��@�� 2
d5^�:�_�?��qz��0:�1,ϰl���w�y�3�K�C�*�I��4.l,{i����'�ɻ��%)�I��"euHW<sH�Z�F���j0�[������:�N�z0q�^��E�ǐY���Kϓf.����Na����ǣ���%���t�����?M���C�)�?M��31�����/�,�OǦ�c�?>�?����9��C�b������O�Y���?�����G��c�?:����b�?�������?z����������������������{����p:��5���Ǣ���������H6v�?>�� tR��?S�@:���PR���^��C������Β�,��Ǐ�t��4�F�kw����������s��3�{����{O���7��;�
�,)&�Z�Y���yך��-��Ya�ӥ�<̸�y�VJBI(�>��Xw�~z�����I�]�Z�Z�*��{O������A��K�7!�*��ȵ�b3(���Ol�����mİ�,��2k��{�(3�Lg1���i�lh���s�#Ԓ�Y ۼ��;K&��l��^��8���K1s�RV\SY�W��j��U��L'a�Q�s�/~�� t������������m��������?�N��S�M����;��fc��������������w$�o�����_�b��׶�N�c��htZ��������)������������*n��_��V�v�ҒBae�p�-M��S,P�
Q姑O?���^u)��ȉ�;�6V
�y�ܗ��	ߍ\�3����ȿ5�tfY��7Q�#����o�c�Fp���D��e1��Q�jG�kc�2ۛ1(��Z���I��vJd�S��8m���4�?���P��el�2�A�o�[��O������<Y⅂�)/�&U�.۝jϮ,�ڍ1(�')/��V�Z(Z�i�Ǚ��h ��r^�چ��rCn8r�Z�+�U��JYiUЃ��*U�-؇�Ek�xl�z����z�*��Ox�*���_
�ӪX�K���>'��,�*Ӡ<����P-���C��tՠ�SEV��*o?4�ȓ:_��b�)�n��&DI�S:�f��l��M���9�+�`��w�^v!jI���S�=�]�4;oKsY*�,緉�^�ؐIc%�Yn�պ->^��t������������p�z�c�������w
��<�������?��k#���Q��T2Mi�LJa3)2��*����Q8Uͨ*�f�4�Ҍ����VSL�QHH���q:��w���������2,O��`7��d-M���Y8���|�gϙEP��7w�R���73�m-��x�Hc��f�rw%�}J����2t�7�Fs�Z�xf1��:\Nwu��底�XA[S�I=�<�j-K�V���+�����y<:�����Q�����;�����N ��r�<vg��t
��ǣ����ZS��e�|a�uNo��5J��l�;�8�jM�É�jC��7��Ta�u�'ꍤ�ɵ�����k���O��Q�6TQ\Yr��-�ej;����Wf G�y�ݟ��U��ēe6�Q����{+���O���#�	����P�Ǿ�W�Sx�+��u<�������_���8��Ǎ��6�1�$�?�{f�1���;�f�������o�Wy�����Q�!-����&Gy����6��策K kk�g� a��@l۳{�  SU-�Lu��T	�	��= |s1��V��'�+�͔�m���ӡ3"���P�J��5i�s��x���z�իp�^�ιT�ZVr���Cd�5�I��Y��>TB6��w}}�|��^�hv�BP�?�����I�7l��2_L�z�
���S2Խ�\C�~F�L�vSg�u��v�nUԣ��qU8�`oJ����EB��2<�i��U�)��^�,;�<��h���*��`�Q�T�;=���swR���0��$l���JdҼ���j��{w�~&ЗB�J�W��u�nğ�A��+yf�Z�+���Xz��Kr1��>ў�C{�$Tѕ3O �4A���C���'�h7r7C��/J�<cd@��sY�:A�|(����vVw4脦�{.@����G��6@�L�dݰt�>,[��;Wi�>� ���[��/@M��˭ ��3ٰ.�����w٘�Y{�p��Fd@�@����� 5&� @�b��MX���'�zV�9k�yA޴��R�-��MM>J~u�C�7d�(�Oݎ���ߵP�gX�76\�B5�В�d��tn��!��1�_Xپ��MԾ�U�*�|��.󁌋�q�@�}���1��6���G^�q"����E�%4<��pٮ����z��Tajk}��D� �҂w��@�+�C��a�p�߁+#�����AOl�Q��V$_�!d��װ.x�����C��؃6�yC�z�~V���	+��oz�G�c�2������$6���-��"I����L�����V<����v!�>j�ȱgaep�X���^��Th]��������ć���>��m�4c��g(�Y��l�)�#���Ν�΍2n�}(�B�]$T�f��t����쭒";/���l4����vv��m�J; Ba՘�\C�7�Q�KՁ�V�;}�i��C��t �\KL۞����3<���v=Eb�m��.���lM~�G�ĵ�����AT�p&_�������J���|i��kv�f>���G����s|Ջ�cU��㯉��H��k�q�X�f���A������aŦaC���x�o�n�	�.#_�wԺ���N�c�1�ȨU\n`<�+�ڦi���INg�@4l��Z_"���~	R	�*�Э�~X~��~��0}��r����ԩ�繏ӥutv$ϭ@VU|��h6�5-԰[,x�7T���O�'�����x�����o�ؿ���,�>���4���(��C����A�bܹJ�	��p��y�Uo�|��w�W������ܱG�Wŵ���*�������	��NA�A�.��~B�7��Q˖�+1��ubg��T��Ă��Rln�S��;���khXp�F׉՟�������%Lrx-�N1��!�8��.�o�o�E�Pa8��9�=�Z����I}��CǄ���b-2�|��o�Ed͑	6�����vh�,��o���t������n-�{lK���¿j<b���ħ�=�#��R��o�:_<��������#Ӵ&��TZ�eYIqY�)2�Q:=RU8�4nD�2�0��,�)#e�M�,��2��o�)v����G��K�'2�p�Y���#P�=�OdW��@Nআ���V|�����~�%���tJV�d3$��ECV%�,��4���Ig #+>SXfPOf��� %�e�:\( <n�2�;���[���gp��?�ҭ��˷�f=��s����e\#�k����d|Ec�O�Mm뭜�BR]�jR���Vꅊԓ*WT|��l�vG��\Kj���D�ߋ���R�*u�����ײ�W����e�r�D�Rm7J���ł.^͝+��Wn��`�;d�������\��=���=��q�uԤ��:_	e��X�*�����H�I���>��D���n�k'ۮ�k[J�-��nr��x^��B��Qh���������&�b�%a!/�j�ʕ��A�E�T�ǜ�N�$�[��ګ�J�\�^�u�|�X^&�IgI.d'���ڶJ���>��E�����h�����zV�\],�G��vG����mM���r��j�F��N�n�;��S�z�	�F�C��D�
?(�� H�z���;R�7�wx�oKW��U�9�;��zW,�u��W�R��r��f�wUЇu��y�\�{��u5�M����� ��0/)��]��ԟ��w8��y�O��'��1��Jx+��9�4�Y����L��E��F:����|߇�����dı�=
�8�	��V�y�;�h�M<��C���[\�sc���yPv4;���̈́;��2^��IQ~���h�a)
�d����!��$�J*�;ƯmHK�$f�����c;���cX�Ms�nn��k'p���A�x�@���@���?�02}1�'�\pd%�v�����M�(������>��?�N����?�o��nK��A�Ϸ3����/`h�f���̐w.�@5�q��]��<<�z��aA�b��=؇Q�C5�Ap1��`����2oʌ��������5BƳ��O�F��d�>a�3�N��hE��h�ZA�v3;P�k��_�
'OMQE#�������>ٹ	0B�\�}Ō��l��p�4 Մ��K�������z��g��k��Slx�{�C��04�:�21��N �3�Kٳ�=G��
 �B����	ϲ�	��8'�o����+���pSD������GF_h��� :���?�����^����W�^q�:�ku�i��ak�� ���=2�6
X/Y��-����Q�����D✴|��/���8��틋��r0������g����W\��oQ\����ۻ�޴� ���b�EJU�c�J�mԾ�����ʃ1���pD���3��l=�k���;;;x�@�
�+�pU ��4�N.�Irۤ�i�x�yi�Mɒ�P�,����ņ�ﴭ�ɩ�u�f�e>,��%w�&���pwc��e�����m�{_>�7a�P4�S0���H*��qf�6�hAސ��B��|\aB}�U���8?�W�.�)�.�1���@�_�X+�����R1��/.1�޹���ƧT,k��d"ǎ�8(Ŕ���QC�����f���Ui��sU���CK%<���:�KH�Qj�Đ]���-�����3����������\�N�7]�o^�}���dM��j�w�����+s�r�d��}_��旝���lۮ��������9�7���(p^�wϜб;]o�[��Z�o{=�?�{���]�ӣ�����E4>�G�i�\���	*3h� 3����N�e��Rs���ߝMG�<T+#h�էZ��� Ql$>�ѭkzSx�ZR��i�0�[��G�l��&^�8�����Y�LL\�F�� �:Ϻe�!^%4�wÙY:J����;�p���Jט�=�;��3���?�v�P˩�/t����h��k��c2_��*�o羂y|K�%���P����2��D��%#1�FvIw�PA\ � \�v1���_trӭ��Z��ɿ��u��j\���}�]�}���G�c�ǈ�6��崩~"�O��$:q�xq{,c�F���b�9��,��4Ȗ������d0��`0��`0���k�n2 0 