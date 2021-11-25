import streamlit as st

whitelist = [
    "0x912d3aDaA10e2b55474E5C351f70079f58003618",
    "0x5852A2a81b444daB67e1248356A509aCd62F854e",
]
user_tier = 1
tier_charges = [5, 4, 3, 2, 1]

# PAGES = {"App1": app1, "App2": app2}
# st.sidebar.title("Navigation")
# selection = st.sidebar.radio("Go to", list(PAGES.keys()))
# https://medium.com/@u.praneel.nihar/building-multi-page-web-app-using-streamlit-7a40d55fa5b4

st.title("Eco Shift")
st.write("Keep your money in your community.")

token_id = st.text_input("Your wallet name (must end in .eco)", key="token_id")

if st.button(
    "Generate Wallet!", key=None, help=None, on_click=None, args=None, kwargs=None
):
    st.write(
        "You have successfully generated your Tier 1 Eco Wallet. Your wallet name is "
        + token_id
        + ". Please keep it safe."
    )
    st.image("image/tier1.png", width=1, use_column_width=True)
st.write("Progress to Tier: " + str(user_tier + 1))
st.progress(80)
address = st.text_input("Address to pay", key="pay_address")
amount = st.text_input("Amount (in eth)", key="pay_address")
show_pay = False
if st.button("Calculate costs"):
    if address in whitelist:
        st.write("Amount to " + address + ": " + amount + " ETH.")
        st.write("Points added: 1")
    else:
        st.write("Amount to " + address + ": " + amount + " ETH.")
        charity_charge = (tier_charges[user_tier - 1] / 100) * int(amount)
        st.write("Amount to charities " + str(charity_charge) + " ETH.")
    show_pay = True

if show_pay == True:
    if st.button("Pay!"):
        if address in whitelist:
            st.write("Payment confirmed. Congratulations you are now Tier 2.")
            st.image("image/tier2.png", use_column_width=True)
        else:
            st.write("Payment confirmed.")
        show_pay = False
