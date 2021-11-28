import streamlit as st

whitelist = [
    "0x912d3aDaA10e2b55474E5C351f70079f58003618",
    "0x5852A2a81b444daB67e1248356A509aCd62F854e",
]
# 0x2812X2a98b213da67e6348354H809aCd62F769a
show_p = False


def app(user_tier, tier_charges):
    whitelist
    st.markdown("#### Pay an address")
    address = st.text_input("Address to pay", key="pay_address")
    amount = st.text_input("Amount (ETH)", key="pay_address")
    show_pay = False
    if st.button("Calculate costs"):
        if address in whitelist:
            st.write("Amount to " + address + ": " + amount + " ETH.")
            st.write(
                "You are sending money to a whitelist address. Points towards next rank: 1"
            )
            user_tier += 1
        else:
            st.write("Amount to " + address + ": " + amount + " ETH.")
            charity_charge = (tier_charges[user_tier - 1] / 100) * float(amount)
            st.write("Amount to charities: " + str(charity_charge) + " ETH.")
        show_pay = True
    if address != "" and amount != "":
        if st.button("Pay!"):
            if address in whitelist:
                st.write("Payment confirmed. Congratulations you are now Tier 2.")
                st.image("image/tier2.png", width=250)
            else:
                st.write("Payment confirmed.")
            show_p = False
    return user_tier
