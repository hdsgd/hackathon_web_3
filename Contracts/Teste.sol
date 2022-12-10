/*
fee_address : 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
starting_bid : 50000000000000000
period : 1670454000
transaction_fee : 100 ->1%
whitelist:
    0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
*/
Adicionar event no paymentsplit ao adicionar novo recipient

Talvez adicionar transfer ownership , melhorar ter e não precisar do que não ter e precisar

métodos internos e externos, cria um e chama o outro, nunca repetir

avaliar uso do safemath para evitar underflow overflow

paymentsplit ajustar quantidade de recipients, eventualmente pode ser um número maior
verificar se o endereço ja existe , e adicionar um método de edição

todos os métodos de escrita DEVE retornar algo, todos que escrevem devem retornar , no minimo bool

adicionar comentários em todas as variaveis

remover método getAddress

pop / delete o array não diminui, só preencido com 0

fazer teste com o owner para garantir que esat tudo ok, possivelmente importar do openzeppelin
